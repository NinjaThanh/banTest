import React, {useEffect, useMemo, useRef, useState, useContext,} from 'react';
import {View, Text, TextInput, Pressable, Image, FlatList, ListRenderItemInfo, Platform, Modal, ScrollView, SafeAreaView, Alert, Animated, PanResponder, Dimensions, Easing, StatusBar,} from 'react-native';
import {SafeAreaInsetsContext, type EdgeInsets,} from 'react-native-safe-area-context';
import type { FirebaseAuthTypes } from '@react-native-firebase/auth';
import firestore, {FirebaseFirestoreTypes as FT,} from '@react-native-firebase/firestore';
import { COLORS as APP_COLORS } from '../../../config/AppConfig';
import Icon from 'react-native-vector-icons/Feather';

export type Freelancer = {
    id: string;
    name: string;
    category: string;
    rating: number;
    avatar?: string;
    intro?: string;
    skills?: string[];
};

type Props = {
    user?: FirebaseAuthTypes.User;
    freelancers?: Freelancer[];
    onPostJob?: () => void;
    onWallet?: () => void;
    onChat?: (f: Freelancer) => void;
    onSeeAll?: () => void;
    onPressFreelancer?: (f: Freelancer) => void;
    mode?: 'client' | 'freelancer';
};

const COLORS = {
    text: APP_COLORS?.text ?? '#000E08',
    primary: APP_COLORS?.primary ?? '#24786D',
    background: '#FFFFFF',
    muted: '#6B7280',
    border: '#E5E7EB',
    star: '#FACC15',
    surface: '#FFFFFF',
    overlay: 'rgba(0,0,0,0.35)',
    chipBg: '#FFFFFF',
    fieldBg: '#FFFFFF',
    danger: '#B91C1C',
    green: '#23A86B',
    greenStrong: '#1B8F5A',
    grayBtn: '#FFFFFF',
};

const CATEGORIES = ['Sửa chữa', 'Thiết kế', 'Web Dev', 'Marketing'] as const;
type Category = (typeof CATEGORIES)[number];

const { height: SCREEN_H } = Dimensions.get('window');
const formatVi = (n: number) => n.toFixed(1).replace('.', ',');
const formatMoney = (n: number) => `${n.toLocaleString('vi-VN')} đ`;
const formatDateTime = (d?: Date | null) => {
    if (!d) return '';
    return d.toLocaleString('vi-VN');
};

/* ================= UTILS ================= */
const normalizeVN = (s: string) =>
    (s || '')
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '');
const splitSkills = (s: string) =>
    s
        .split(',')
        .map(x => x.trim())
        .filter(Boolean);
const col = () => firestore().collection('freelancers');
const toFreelancer = (d: FT.DocumentSnapshot): Freelancer => {
    const x = d.data() as any;
    return {
        id: d.id,
        name: x?.name ?? '',
        category: x?.category ?? '',
        rating: Number(x?.rating ?? 0),
        avatar: x?.avatar,
        intro: x?.intro,
        skills: Array.isArray(x?.skills) ? x.skills : [],
    };
};

type UseFreelancersOpts = {
    queryText?: string;
    category?: string;
    limit?: number;
    orderBy?: 'rating' | 'createdAt';
};

function useFreelancers(opts: UseFreelancersOpts) {
    const { queryText = '', category, limit = 20, orderBy = 'rating' } = opts;
    const [items, setItems] = useState<Freelancer[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        setLoading(true);
        setError(null);
        let q: FT.Query = col();

        if (category?.trim()) {
            q = q.where('categoryLower', '==', category.trim().toLowerCase());
        }

        q =
            orderBy === 'rating'
                ? q.orderBy('rating', 'desc')
                : q.orderBy('createdAt', 'desc');
        q = q.limit(limit);

        const unsub = q.onSnapshot(
            snap => {
                let rows = snap.docs.map(toFreelancer);
                const k = normalizeVN(queryText.trim());
                if (k) {
                    rows = rows.filter(f => {
                        const hay =
                            normalizeVN(f.name) +
                            ' ' +
                            normalizeVN(f.category) +
                            ' ' +
                            normalizeVN((f.skills || []).join(' '));
                        return hay.includes(k);
                    });
                }
                setItems(rows);
                setLoading(false);
            },
            e => {
                setError(e?.message || 'Load thất bại');
                setLoading(false);
            },
        );

        return () => unsub();
    }, [queryText, category, limit, orderBy]);

    return { items, loading, error };
}

/* ============ WALLET HOOK ============ */

type WalletTx = {
    id: string;
    type: 'deposit' | 'withdraw' | 'transfer_in' | 'transfer_out';
    amount: number;
    status: 'pending' | 'success' | 'failed';
    createdAt?: Date | null;
    note?: string;
    otherAccountNumber?: string; // STK bên kia (ví SkillHub)

    // Ngân hàng khi rút
    bankName?: string;
    bankAccountNumber?: string;
    bankAccountHolder?: string;
};

type WalletDoc = {
    balance: number;
    updatedAt?: FT.Timestamp;
    userId?: string;
    userEmail?: string;
    accountNumber?: string; // STK ví SkillHub
};

const useWallet = (uid?: string | null) => {
    const [balance, setBalance] = useState<number>(0);
    const [loadingBalance, setLoadingBalance] = useState(true);
    const [txs, setTxs] = useState<WalletTx[]>([]);
    const [loadingTxs, setLoadingTxs] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // balance
    useEffect(() => {
        if (!uid) {
            setBalance(0);
            setLoadingBalance(false);
            return;
        }
        setLoadingBalance(true);
        const ref = firestore().collection('wallets').doc(uid);
        const unsub = ref.onSnapshot(
            snap => {
                const data = snap.data() as WalletDoc | undefined;
                setBalance(Number(data?.balance ?? 0));
                setLoadingBalance(false);
            },
            e => {
                setError(e?.message || 'Không tải được ví');
                setLoadingBalance(false);
            },
        );
        return () => unsub();
    }, [uid]);

    // transactions
    useEffect(() => {
        if (!uid) {
            setTxs([]);
            setLoadingTxs(false);
            return;
        }
        setLoadingTxs(true);
        const q = firestore()
            .collection('walletTransactions')
            .where('userId', '==', uid)
            .orderBy('createdAt', 'desc')
            .limit(50);

        const unsub = q.onSnapshot(
            snap => {
                const rows: WalletTx[] = snap.docs.map(d => {
                    const x = d.data() as any;
                    const ts = x?.createdAt as FT.Timestamp | undefined;
                    const rawType = x?.type;
                    const t: WalletTx['type'] =
                        rawType === 'withdraw'
                            ? 'withdraw'
                            : rawType === 'transfer_in'
                                ? 'transfer_in'
                                : rawType === 'transfer_out'
                                    ? 'transfer_out'
                                    : 'deposit';

                    return {
                        id: d.id,
                        type: t,
                        amount: Number(x?.amount ?? 0),
                        status: x?.status ?? 'success',
                        createdAt: ts ? ts.toDate() : undefined,
                        note: x?.note ?? '',
                        otherAccountNumber: x?.otherAccountNumber ?? '',
                        bankName: x?.bankName ?? '',
                        bankAccountNumber: x?.bankAccountNumber ?? '',
                        bankAccountHolder: x?.bankAccountHolder ?? '',
                    };
                });
                setTxs(rows);
                setLoadingTxs(false);
            },
            e => {
                setError(e?.message || 'Không tải được lịch sử giao dịch');
                setLoadingTxs(false);
            },
        );

        return () => unsub();
    }, [uid]);

    return {
        balance,
        loadingBalance,
        txs,
        loadingTxs,
        error,
    };
};

/* ================= SMALL UI PARTS ================= */
const StarRating: React.FC<{ value: number; size?: number }> = ({
                                                                    value,
                                                                    size = 14,
                                                                }) => {
    const full = Math.floor(value);
    const half = value - full >= 0.5 ? 1 : 0;
    const empty = 5 - full - half;
    const stars =
        '★'.repeat(full) +
        (half ? '☆' : '') +
        '☆'.repeat(Math.max(0, empty - (half ? 1 : 0)));

    return (
        <Text
            style={{
                fontSize: size,
                lineHeight: size + 3,
                color: COLORS.star,
                letterSpacing: 1,
            }}>
            {stars}
        </Text>
    );
};

const ActionCard: React.FC<{
    title: string;
    color: string;
    onPress?: () => void;
    iconName: React.ComponentProps<typeof Icon>['name'];
    disabled?: boolean;
}> = ({ title, color, onPress, iconName, disabled = false }) => (
    <Pressable
        accessibilityRole="button"
        onPress={disabled ? undefined : onPress}
        hitSlop={10}
        android_ripple={{ color: 'rgba(255,255,255,0.25)', borderless: false }}
        style={({ pressed }) => ({
            width: 104,
            height: 104,
            borderRadius: 22,
            backgroundColor: disabled ? '#A3A3A3' : color,
            justifyContent: 'center',
            alignItems: 'center',
            opacity: pressed ? 0.9 : 1,
        })}>
        <Icon
            name={iconName}
            size={28}
            color="#FFFFFF"
            style={{ marginBottom: 6 }}
        />
        <Text
            style={{
                color: 'white',
                fontSize: 14,
                fontWeight: '700',
                textAlign: 'center',
            }}
            numberOfLines={2}>
            {title}
        </Text>
    </Pressable>
);

const Avatar: React.FC<{ uri?: string; size?: number }> = ({
                                                               uri,
                                                               size = 44,
                                                           }) =>
    uri ? (
        <Image
            source={{ uri }}
            style={{
                width: size,
                height: size,
                borderRadius: size / 2,
                backgroundColor: '#EEF2F7',
            }}
        />
    ) : (
        <View
            style={{
                width: size,
                height: size,
                borderRadius: size / 2,
                backgroundColor: '#EEF2F7',
                justifyContent: 'center',
                alignItems: 'center',
            }}>
            <Text style={{ color: COLORS.muted, fontSize: size * 0.36 }}>👤</Text>
        </View>
    );

const FreelancerCard: React.FC<{ item: Freelancer; onPress?: () => void }> = ({
                                                                                  item,
                                                                                  onPress,
                                                                              }) => (
    <Pressable
        accessibilityRole="button"
        onPress={onPress}
        hitSlop={8}
        android_ripple={{ color: 'rgba(0,0,0,0.06)' }}
        style={({ pressed }) => ({
            backgroundColor: COLORS.surface,
            borderRadius: 18,
            paddingHorizontal: 16,
            paddingVertical: 14,
            marginBottom: 12,
            borderWidth: 1,
            borderColor: COLORS.border,
            ...(Platform.OS === 'ios'
                ? {
                    shadowColor: '#000',
                    shadowOpacity: 0.04,
                    shadowRadius: 8,
                    shadowOffset: { width: 0, height: 4 },
                }
                : { elevation: 1 }),
            opacity: pressed ? 0.96 : 1,
        })}>
        <View style={{ flexDirection: 'row', alignItems: 'center' }}>
            <Avatar uri={item.avatar} />
            <View style={{ marginLeft: 12, flex: 1 }}>
                <Text style={{ color: COLORS.text, fontSize: 16, fontWeight: '700' }}>
                    {item.name}
                </Text>
                <Text style={{ color: COLORS.primary, fontSize: 13, marginTop: 2 }}>
                    {item.category}
                </Text>
                <View
                    style={{ flexDirection: 'row', alignItems: 'center', marginTop: 6 }}>
                    <StarRating value={item.rating} />
                    <Text
                        style={{
                            marginLeft: 8,
                            color: COLORS.text,
                            fontSize: 13,
                            opacity: 0.8,
                        }}>
                        {formatVi(item.rating)}
                    </Text>
                </View>
            </View>
        </View>
    </Pressable>
);

const Label = ({ children }: { children: React.ReactNode }) => (
    <Text style={{ fontSize: 12, color: COLORS.muted, marginBottom: 6 }}>
        {children}
    </Text>
);

const Field = ({
                   value,
                   onChangeText,
                   placeholder,
                   multiline = false,
                   keyboardType = 'default',
               }: any) => (
    <TextInput
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor="#9CA3AF"
        keyboardType={keyboardType}
        multiline={multiline}
        numberOfLines={multiline ? 4 : 1}
        style={{
            borderWidth: 1,
            borderColor: COLORS.border,
            borderRadius: 12,
            paddingHorizontal: 12,
            paddingVertical: multiline ? 12 : 10,
            minHeight: multiline ? 96 : 44,
            color: COLORS.text,
            backgroundColor: COLORS.fieldBg,
        }}
    />
);

/* ================= MAIN ================= */
const MyJobsTab: React.FC<Props> = props => {
    const {
        freelancers,
        onPostJob,
        onWallet,
        onChat,
        onSeeAll,
        onPressFreelancer,
        user,
        mode = 'client',
    } = props;

    const currentUid = user?.uid ?? null;
    const isClient = mode === 'client';

    const insetsFromCtx = useContext(SafeAreaInsetsContext);
    const insets: EdgeInsets =
        insetsFromCtx ?? { top: 0, bottom: 0, left: 0, right: 0 };

    const [expanded, setExpanded] = useState(false);
    const [selected, setSelected] = useState<Freelancer | null>(null);
    const [showDetail, setShowDetail] = useState(false);
    const [query, setQuery] = useState('');
    const [showPostJob, setShowPostJob] = useState(false);

    // Wallet modal state
    const [showWalletModal, setShowWalletModal] = useState(false);
    const [walletMode, setWalletMode] = useState<
        'deposit' | 'withdraw' | 'transfer'
    >('deposit');
    const [walletAmount, setWalletAmount] = useState('');
    const [walletNote, setWalletNote] = useState('');
    const [walletSubmitting, setWalletSubmitting] = useState(false);

    // số tài khoản người nhận khi chuyển tiền
    const [walletTargetAccount, setWalletTargetAccount] = useState('');

    // thông tin ngân hàng khi rút tiền
    const [bankName, setBankName] = useState('');
    const [bankAccountNumber, setBankAccountNumber] = useState('');
    const [bankAccountHolder, setBankAccountHolder] = useState('');

    // Firestore wallet data
    const {
        balance,
        loadingBalance,
        txs,
        loadingTxs,
        error: walletError,
    } = useWallet(currentUid);

    const INITIAL_COUNT = 4;

    const { SNAP_TOP, SNAP_MID, SNAP_MIN, SNAP_MAX } = useMemo(() => {
        const top = Math.max(insets.top - 8, 0);
        const mid = SCREEN_H * 0.4;
        const max = SCREEN_H * 0.86;
        return { SNAP_TOP: top, SNAP_MID: mid, SNAP_MIN: top, SNAP_MAX: max };
    }, [insets.top]);

    // Firestore data freelancers
    const { items, loading, error } = useFreelancers({
        queryText: query,
        limit: expanded ? 50 : 20,
        orderBy: 'rating',
    });
    const baseData = freelancers?.length ? freelancers : items;
    const filteredData = baseData;
    const visibleData = useMemo(
        () => (expanded ? filteredData : filteredData.slice(0, INITIAL_COUNT)),
        [expanded, filteredData],
    );

    const handleSeeAll = () =>
        onSeeAll ? onSeeAll() : setExpanded(v => !v);
    const seeAllLabel = onSeeAll ? 'Xem tất cả' : expanded ? 'Thu gọn' : 'Xem tất cả';

    const sheetY = useRef(new Animated.Value(SCREEN_H * 0.4)).current;
    const dragOffsetY = useRef(SCREEN_H * 0.4);
    const animateTo = (toY: number) => {
        Animated.timing(sheetY, {
            toValue: toY,
            duration: 220,
            easing: Easing.out(Easing.cubic),
            useNativeDriver: false,
        }).start(() => {
            dragOffsetY.current = toY;
        });
    };

    const openDetail = (item: Freelancer) => {
        if (onPressFreelancer) {
            return onPressFreelancer(item);
        }
        setSelected(item);
        setShowDetail(true);
        sheetY.setValue(SNAP_MID);
        dragOffsetY.current = SNAP_MID;
    };

    const handleQuickChat = () => {
        if (!isClient) return;
        if (!selected) {
            return Alert.alert(
                'Chọn freelancer',
                'Hãy chạm vào một freelancer trước, rồi bấm Chat.',
            );
        }
        if (currentUid && selected.id === currentUid) {
            return Alert.alert('Không thể chat', 'Bạn không thể chat với chính mình.');
        }
        onChat?.(selected);
    };

    // Thuê ngay
    const handleHireNow = async () => {
        if (!isClient) return;

        if (!selected) {
            return Alert.alert(
                'Chọn freelancer',
                'Hãy chạm vào một freelancer trước, rồi bấm Thuê ngay.',
            );
        }

        if (!user) {
            return Alert.alert(
                'Cần đăng nhập',
                'Bạn cần đăng nhập để gửi yêu cầu thuê.',
            );
        }

        if (currentUid && selected.id === currentUid) {
            return Alert.alert('Không thể thuê', 'Bạn không thể thuê chính mình.');
        }

        try {
            const now = firestore.FieldValue.serverTimestamp();
            await firestore().collection('notifications').add({
                type: 'hire_request',
                fromUserId: user.uid,
                fromName: user.displayName ?? '',
                toUserId: selected.id,
                toName: selected.name,
                status: 'pending',
                createdAt: now,
                read: false,
            });

            setShowDetail(false);
            Alert.alert(
                'Đã gửi yêu cầu',
                `Đã gửi yêu cầu thuê đến ${selected.name}.`,
            );
        } catch (e: any) {
            Alert.alert(
                'Lỗi',
                e?.message ?? 'Không thể gửi yêu cầu thuê. Vui lòng thử lại sau.',
            );
        }
    };

    const snapToNearest = () => {
        const y = dragOffsetY.current;
        // Kéo gần cuối màn hình thì đóng sheet
        if (y > SCREEN_H * 0.78) {
            setShowDetail(false);
            return;
        }
        const dTop = Math.abs(y - SNAP_TOP);
        const dMid = Math.abs(y - SNAP_MID);
        animateTo(dTop < dMid ? SNAP_TOP : SNAP_MID);
    };

    const panResponder = useRef(
        PanResponder.create({
            onMoveShouldSetPanResponder: (_e, g) => Math.abs(g.dy) > 4,
            onPanResponderGrant: () => {
                sheetY.stopAnimation((val: number) => {
                    dragOffsetY.current = val;
                });
            },
            onPanResponderMove: (_e, g) => {
                const next = Math.min(
                    Math.max(dragOffsetY.current + g.dy, SNAP_MIN),
                    SNAP_MAX,
                );
                sheetY.setValue(next);
            },
            onPanResponderRelease: (_e, g) => {
                dragOffsetY.current = Math.min(
                    Math.max(dragOffsetY.current + g.dy, SNAP_MIN),
                    SNAP_MAX,
                );
                snapToNearest();
            },
            onPanResponderTerminate: () => {
                snapToNearest();
            },
        }),
    ).current;

    const sheetStyle: any = {
        position: 'absolute' as const,
        left: 0,
        right: 0,
        top: sheetY, // Animated.Value
        backgroundColor: COLORS.surface,
        borderTopLeftRadius: 24,
        borderTopRightRadius: 24,
        paddingHorizontal: 16,
        paddingBottom: 16,
        ...(Platform.OS === 'ios'
            ? {
                shadowColor: '#000',
                shadowOpacity: 0.12,
                shadowRadius: 16,
                shadowOffset: { width: 0, height: -4 },
            }
            : { elevation: 10 }),
    };

    useEffect(() => {
        StatusBar.setBarStyle(showDetail ? 'light-content' : 'dark-content', true);
        if (Platform.OS === 'android') {
            StatusBar.setBackgroundColor(
                showDetail ? '#00000055' : 'transparent',
                true,
            );
            StatusBar.setTranslucent(true);
        }
        return () => {
            StatusBar.setBarStyle('dark-content', true);
            if (Platform.OS === 'android') {
                StatusBar.setBackgroundColor('transparent', true);
                StatusBar.setTranslucent(true);
            }
        };
    }, [showDetail]);

    const bottomSafe = (insets.bottom ?? 0) + 56;

    /* --------- Post Job --------- */
    const [title, setTitle] = useState('');
    const [desc, setDesc] = useState('');
    const [category, setCategory] = useState<Category>('Sửa chữa');
    const [budget, setBudget] = useState('');
    const [city, setCity] = useState('');
    const [skillsText, setSkillsText] = useState('');
    const [posterName, setPosterName] = useState('');
    const [posterContact, setPosterContact] = useState('');
    const [posterAddress, setPosterAddress] = useState('');

    const resetForm = () => {
        setTitle('');
        setDesc('');
        setCategory('Sửa chữa');
        setBudget('');
        setCity('');
        setSkillsText('');
        setPosterName('');
        setPosterContact('');
        setPosterAddress('');
    };

    const handleOpenPostJob = () => {
        if (!isClient) return;
        if (onPostJob) return onPostJob();
        if (!user) {
            Alert.alert('Cần đăng nhập', 'Bạn cần đăng nhập để đăng việc.');
            return;
        }
        setPosterName(user.displayName ?? '');
        setPosterContact(user.email ?? '');
        setShowPostJob(true);
    };

    const submitPostJob = async () => {
        if (!user) {
            return Alert.alert('Cần đăng nhập', 'Bạn cần đăng nhập để đăng việc.');
        }
        if (!title.trim() || !desc.trim()) {
            return Alert.alert(
                'Thiếu thông tin',
                'Vui lòng nhập Tiêu đề và Mô tả.',
            );
        }
        if (!city.trim()) {
            return Alert.alert(
                'Thiếu Tỉnh/Thành phố',
                'Vui lòng nhập Tỉnh/Thành phố.',
            );
        }
        const budgetNum = Number(budget);
        if (Number.isNaN(budgetNum) || budgetNum < 0) {
            return Alert.alert(
                'Ngân sách không hợp lệ',
                'Vui lòng nhập số >= 0.',
            );
        }

        try {
            const now = firestore.FieldValue.serverTimestamp();
            await firestore().collection('jobs').add({
                title: title.trim(),
                description: desc.trim(),
                category,
                categoryLower: category.toLowerCase(),
                budget: budgetNum,
                city: city.trim(),
                skills: splitSkills(skillsText),
                ownerId: user.uid,
                posterName: posterName.trim(),
                posterContact: posterContact.trim(),
                posterAddress: posterAddress.trim(),
                createdAt: now,
                updatedAt: now,
            });
            Alert.alert('Thành công', 'Đăng việc thành công.');
            setShowPostJob(false);
            resetForm();
        } catch (e: any) {
            Alert.alert('Lỗi', e?.message ?? 'Không thể đăng việc.');
        }
    };

    /* --------- Wallet handlers --------- */
    const walletCanSubmit = useMemo(() => {
        const n = Number(walletAmount);
        if (Number.isNaN(n) || n <= 0) return false;

        if (walletMode === 'withdraw' || walletMode === 'transfer') {
            if (n > balance) return false;
        }

        if (walletMode === 'transfer' && !walletTargetAccount.trim()) {
            return false;
        }

        // Rút về ngân hàng: bắt buộc nhập đầy đủ
        if (walletMode === 'withdraw') {
            if (
                !bankName.trim() ||
                !bankAccountNumber.trim() ||
                !bankAccountHolder.trim()
            ) {
                return false;
            }
        }

        return true;
    }, [
        walletAmount,
        walletMode,
        balance,
        walletTargetAccount,
        bankName,
        bankAccountNumber,
        bankAccountHolder,
    ]);

    const handleOpenWallet = () => {
        if (onWallet) return onWallet();
        if (!user || !currentUid) {
            Alert.alert('Cần đăng nhập', 'Bạn cần đăng nhập để sử dụng ví.');
            return;
        }
        setShowWalletModal(true);
    };

    const handleWalletSubmit = async () => {
        if (!user || !currentUid) {
            return Alert.alert('Cần đăng nhập', 'Bạn cần đăng nhập để sử dụng ví.');
        }

        const n = Number(walletAmount);
        if (Number.isNaN(n) || n <= 0) {
            return Alert.alert(
                'Số tiền không hợp lệ',
                'Vui lòng nhập số tiền > 0.',
            );
        }

        if (
            (walletMode === 'withdraw' || walletMode === 'transfer') &&
            n > balance
        ) {
            return Alert.alert(
                'Không đủ số dư',
                'Số dư ví không đủ để thực hiện giao dịch này.',
            );
        }

        // Rút về ngân hàng: kiểm tra thêm
        if (walletMode === 'withdraw') {
            if (!bankName.trim() || !bankAccountNumber.trim() || !bankAccountHolder.trim()) {
                return Alert.alert(
                    'Thiếu thông tin ngân hàng',
                    'Vui lòng nhập đầy đủ: Tên ngân hàng, Số tài khoản và Tên chủ tài khoản.',
                );
            }
        }

        // CHUYỂN TIỀN BẰNG SỐ TÀI KHOẢN (ví SkillHub → ví SkillHub)
        if (walletMode === 'transfer') {
            if (!walletTargetAccount.trim()) {
                return Alert.alert(
                    'Thiếu thông tin',
                    'Vui lòng nhập số tài khoản người nhận.',
                );
            }

            try {
                setWalletSubmitting(true);
                const targetAccountNumber = walletTargetAccount.trim();

                // tìm ví người nhận theo số tài khoản trong collection wallets
                const walletSnap = await firestore()
                    .collection('wallets')
                    .where('accountNumber', '==', targetAccountNumber)
                    .limit(1)
                    .get();

                if (walletSnap.empty) {
                    setWalletSubmitting(false);
                    return Alert.alert(
                        'Không tìm thấy tài khoản',
                        'Không tìm thấy ví nào với số tài khoản này.',
                    );
                }

                const targetWalletDoc = walletSnap.docs[0];
                const targetUid = targetWalletDoc.id;
                const targetWalletData = targetWalletDoc.data() as WalletDoc;
                const targetUserEmail = targetWalletData.userEmail ?? '';
                const targetAccountFromDoc =
                    targetWalletData.accountNumber ?? targetAccountNumber;

                if (targetUid === currentUid) {
                    setWalletSubmitting(false);
                    return Alert.alert(
                        'Không hợp lệ',
                        'Bạn không thể chuyển tiền cho chính mình.',
                    );
                }

                const now = firestore.FieldValue.serverTimestamp();

                const walletRef = firestore()
                    .collection('wallets')
                    .doc(currentUid);
                const targetWalletRef = firestore()
                    .collection('wallets')
                    .doc(targetUid);

                const txRefOut = firestore()
                    .collection('walletTransactions')
                    .doc();
                const txRefIn = firestore()
                    .collection('walletTransactions')
                    .doc();

                await firestore().runTransaction(async t => {
                    const snap = await t.get(walletRef);
                    const data = snap.data() as WalletDoc | undefined;
                    const currentBalance = Number(data?.balance ?? 0);

                    if (currentBalance < n) {
                        throw new Error('Số dư không đủ để chuyển.');
                    }

                    const senderAccountNumber = data?.accountNumber ?? '';

                    const targetSnapInner = await t.get(targetWalletRef);
                    const targetDataInner =
                        targetSnapInner.data() as WalletDoc | undefined;
                    const targetBalance = Number(targetDataInner?.balance ?? 0);

                    const newSenderBalance = currentBalance - n;
                    const newTargetBalance = targetBalance + n;

                    // cập nhật ví người gửi
                    t.set(
                        walletRef,
                        {
                            balance: newSenderBalance,
                            updatedAt: now,
                            userId: currentUid,
                            userEmail: user.email ?? '',
                        },
                        { merge: true },
                    );

                    // cập nhật ví người nhận
                    t.set(
                        targetWalletRef,
                        {
                            balance: newTargetBalance,
                            updatedAt: now,
                            userId: targetUid,
                            userEmail: targetUserEmail,
                        },
                        { merge: true },
                    );

                    // transaction cho người gửi
                    t.set(txRefOut, {
                        userId: currentUid,
                        userEmail: user.email ?? '',
                        type: 'transfer_out',
                        amount: n,
                        status: 'success',
                        createdAt: now,
                        note: walletNote.trim(),
                        otherUserId: targetUid,
                        otherAccountNumber: targetAccountFromDoc,
                    });

                    // transaction cho người nhận
                    t.set(txRefIn, {
                        userId: targetUid,
                        userEmail: targetUserEmail,
                        type: 'transfer_in',
                        amount: n,
                        status: 'success',
                        createdAt: now,
                        note: walletNote.trim(),
                        otherUserId: currentUid,
                        otherAccountNumber: senderAccountNumber,
                    });
                });

                Alert.alert(
                    'Thành công',
                    `Đã chuyển ${formatMoney(n)} tới tài khoản ${targetAccountFromDoc}.`,
                );
                setWalletAmount('');
                setWalletNote('');
                setWalletTargetAccount('');
            } catch (e: any) {
                Alert.alert(
                    'Lỗi',
                    e?.message ??
                    'Không thể thực hiện chuyển tiền. Vui lòng thử lại.',
                );
            } finally {
                setWalletSubmitting(false);
            }

            return;
        }

        // Nạp / Rút (ví SkillHub)
        if (walletMode === 'withdraw' && n > balance) {
            return Alert.alert(
                'Không đủ số dư',
                'Số dư ví không đủ để rút số tiền này.',
            );
        }

        try {
            setWalletSubmitting(true);
            const now = firestore.FieldValue.serverTimestamp();
            const walletRef = firestore().collection('wallets').doc(currentUid);
            const txRef = firestore().collection('walletTransactions').doc();

            await firestore().runTransaction(async t => {
                const snap = await t.get(walletRef);
                const data = snap.data() as WalletDoc | undefined;
                const currentBalance = Number(data?.balance ?? 0);
                const newBalance =
                    walletMode === 'deposit'
                        ? currentBalance + n
                        : currentBalance - n;

                if (newBalance < 0) {
                    throw new Error('Số dư không đủ để rút.');
                }

                t.set(
                    walletRef,
                    {
                        balance: newBalance,
                        updatedAt: now,
                        userId: currentUid,
                        userEmail: user.email ?? '',
                    },
                    { merge: true },
                );

                t.set(txRef, {
                    userId: currentUid,
                    userEmail: user.email ?? '',
                    type: walletMode,
                    amount: n,
                    status: 'success',
                    createdAt: now,
                    note: walletNote.trim(),
                    otherAccountNumber: '',
                    bankName: walletMode === 'withdraw' ? bankName.trim() : '',
                    bankAccountNumber:
                        walletMode === 'withdraw' ? bankAccountNumber.trim() : '',
                    bankAccountHolder:
                        walletMode === 'withdraw' ? bankAccountHolder.trim() : '',
                });
            });

            Alert.alert(
                'Thành công',
                walletMode === 'deposit'
                    ? 'Nạp tiền thành công.'
                    : 'Rút tiền thành công.',
            );
            setWalletAmount('');
            setWalletNote('');
            setBankName('');
            setBankAccountNumber('');
            setBankAccountHolder('');
        } catch (e: any) {
            Alert.alert(
                'Lỗi',
                e?.message ?? 'Không thể thực hiện giao dịch. Vui lòng thử lại.',
            );
        } finally {
            setWalletSubmitting(false);
        }
    };

    const renderWalletTxItem = ({ item }: { item: WalletTx }) => {
        const isIncome = item.type === 'deposit' || item.type === 'transfer_in';
        const sign = isIncome ? '+' : '-';
        const color = isIncome ? COLORS.green : COLORS.danger;
        const iconName = isIncome ? 'arrow-down-circle' : 'arrow-up-circle';

        let title = 'Giao dịch';
        if (item.type === 'deposit') title = 'Nạp tiền';
        else if (item.type === 'withdraw') title = 'Rút tiền';
        else if (item.type === 'transfer_in')
            title = `Nhận từ tài khoản ${item.otherAccountNumber || ''}`.trim();
        else if (item.type === 'transfer_out')
            title = `Chuyển tới tài khoản ${item.otherAccountNumber || ''}`.trim();

        return (
            <View
                style={{
                    flexDirection: 'row',
                    alignItems: 'center',
                    paddingVertical: 10,
                    borderBottomWidth: 1,
                    borderBottomColor: '#F3F4F6',
                }}>
                <Icon
                    name={iconName}
                    size={20}
                    color={color}
                    style={{ marginRight: 10 }}
                />
                <View style={{ flex: 1 }}>
                    <Text
                        style={{
                            color: COLORS.text,
                            fontWeight: '700',
                            marginBottom: 2,
                        }}>
                        {title}
                    </Text>
                    {!!item.note && (
                        <Text
                            numberOfLines={1}
                            style={{ color: COLORS.muted, fontSize: 12 }}>
                            {item.note}
                        </Text>
                    )}
                    {!!item.bankName && item.type === 'withdraw' && (
                        <Text
                            numberOfLines={1}
                            style={{ color: COLORS.muted, fontSize: 11 }}>
                            Ngân hàng: {item.bankName} • {item.bankAccountNumber} •{' '}
                            {item.bankAccountHolder}
                        </Text>
                    )}
                    <Text
                        style={{ color: COLORS.muted, fontSize: 11, marginTop: 2 }}>
                        {formatDateTime(item.createdAt ?? null)}
                    </Text>
                </View>
                <Text style={{ color, fontWeight: '700', marginLeft: 10 }}>
                    {sign} {formatMoney(item.amount)}
                </Text>
            </View>
        );
    };

    /* ================= RENDER ================= */
    return (
        <View
            style={{
                flex: 1,
                backgroundColor: COLORS.background,
                paddingHorizontal: 16,
            }}>
            <StatusBar
                translucent
                backgroundColor="transparent"
                barStyle="dark-content"
            />

            {/* SEARCH */}
            <View style={{ paddingTop: 8, paddingBottom: 12 }}>
                <View
                    style={{
                        flexDirection: 'row',
                        alignItems: 'center',
                        height: 44,
                        borderRadius: 999,
                        borderWidth: 1,
                        borderColor: COLORS.border,
                        backgroundColor: '#FFFFFF',
                        paddingHorizontal: 12,
                    }}>
                    <Icon
                        name="search"
                        size={18}
                        color="#111827"
                        style={{ marginRight: 8 }}
                    />
                    <TextInput
                        value={query}
                        onChangeText={setQuery}
                        placeholder="Tìm freelancer..."
                        placeholderTextColor="#9CA3AF"
                        style={{
                            flex: 1,
                            fontSize: 14,
                            color: COLORS.text,
                            paddingVertical: 0,
                        }}
                        returnKeyType="search"
                    />
                </View>
            </View>

            {/* ACTIONS */}
            <View style={{ paddingBottom: 12 }}>
                <View
                    style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
                    {isClient && (
                        <ActionCard
                            title="Đăng việc"
                            color={COLORS.green}
                            iconName="plus-circle"
                            onPress={handleOpenPostJob}
                        />
                    )}

                    <ActionCard
                        title="Nạp/Rút/Chuyển"
                        color="#4F46E5"
                        iconName="credit-card"
                        onPress={handleOpenWallet}
                    />

                    {isClient && (
                        <ActionCard
                            title="Chat"
                            color="#7C3AED"
                            iconName="message-circle"
                            onPress={handleQuickChat}
                            disabled={
                                !selected ||
                                (selected && currentUid != null && selected.id === currentUid)
                            }
                        />
                    )}
                </View>
                {isClient && selected && (
                    <Text
                        style={{
                            marginTop: 8,
                            textAlign: 'right',
                            color: COLORS.muted,
                            fontSize: 12,
                        }}>
                        Đã chọn: {selected.name} • {selected.category}
                    </Text>
                )}
            </View>

            {/* LIST */}
            <FlatList
                data={visibleData}
                keyExtractor={it => it.id}
                renderItem={({ item }: ListRenderItemInfo<Freelancer>) => (
                    <FreelancerCard item={item} onPress={() => openDetail(item)} />
                )}
                ListHeaderComponent={
                    <View
                        style={{
                            flexDirection: 'row',
                            alignItems: 'center',
                            justifyContent: 'space-between',
                            marginTop: 12,
                            marginBottom: 12,
                        }}>
                        <Text
                            style={{ color: COLORS.text, fontSize: 18, fontWeight: '800' }}>
                            Freelancers
                        </Text>
                        <Pressable hitSlop={8} onPress={handleSeeAll}>
                            <Text
                                style={{
                                    color: COLORS.primary,
                                    fontSize: 14,
                                    fontWeight: '700',
                                }}>
                                {seeAllLabel}
                            </Text>
                        </Pressable>
                    </View>
                }
                contentContainerStyle={{
                    paddingBottom: bottomSafe + 24,
                    backgroundColor: '#FFFFFF',
                }}
                showsVerticalScrollIndicator={false}
                ListEmptyComponent={
                    <View style={{ paddingVertical: 32, alignItems: 'center' }}>
                        <Text style={{ color: COLORS.muted }}>
                            {loading
                                ? 'Đang tải…'
                                : error
                                    ? `Lỗi: ${error}`
                                    : `Không tìm thấy kết quả cho “${query}”.`}
                        </Text>
                    </View>
                }
            />

            {/* DETAIL BOTTOM SHEET */}
            {showDetail && selected && (
                <View
                    pointerEvents="box-none"
                    style={{
                        position: 'absolute',
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        backgroundColor: COLORS.overlay,
                    }}>
                    <Animated.View style={sheetStyle} {...panResponder.panHandlers}>
                        <View
                            style={{
                                alignItems: 'center',
                                paddingTop: 8,
                                paddingBottom: 4,
                            }}>
                            <View
                                style={{
                                    width: 40,
                                    height: 4,
                                    borderRadius: 999,
                                    backgroundColor: '#D1D5DB',
                                }}
                            />
                        </View>

                        <View
                            style={{
                                flexDirection: 'row',
                                alignItems: 'center',
                                marginTop: 12,
                            }}>
                            <Avatar uri={selected.avatar} size={56} />
                            <View style={{ marginLeft: 12, flex: 1 }}>
                                <Text
                                    style={{
                                        color: COLORS.text,
                                        fontSize: 18,
                                        fontWeight: '800',
                                    }}>
                                    {selected.name}
                                </Text>
                                <Text
                                    style={{
                                        color: COLORS.primary,
                                        fontSize: 13,
                                        marginTop: 2,
                                    }}>
                                    {selected.category}
                                </Text>
                                <View
                                    style={{
                                        flexDirection: 'row',
                                        alignItems: 'center',
                                        marginTop: 6,
                                    }}>
                                    <StarRating value={selected.rating} />
                                    <Text
                                        style={{
                                            marginLeft: 8,
                                            color: COLORS.text,
                                            fontSize: 13,
                                            opacity: 0.8,
                                        }}>
                                        {formatVi(selected.rating)} / 5.0
                                    </Text>
                                </View>
                            </View>
                        </View>

                        {selected.intro && (
                            <Text
                                style={{
                                    marginTop: 12,
                                    color: COLORS.text,
                                    fontSize: 13,
                                }}>
                                {selected.intro}
                            </Text>
                        )}

                        {selected.skills && selected.skills.length > 0 && (
                            <View style={{ marginTop: 10, flexDirection: 'row', flexWrap: 'wrap' }}>
                                {selected.skills.map(s => (
                                    <View
                                        key={s}
                                        style={{
                                            paddingHorizontal: 10,
                                            paddingVertical: 4,
                                            borderRadius: 999,
                                            borderWidth: 1,
                                            borderColor: COLORS.border,
                                            marginRight: 8,
                                            marginBottom: 8,
                                            backgroundColor: COLORS.chipBg,
                                        }}>
                                        <Text
                                            style={{
                                                fontSize: 12,
                                                color: COLORS.muted,
                                            }}>
                                            {s}
                                        </Text>
                                    </View>
                                ))}
                            </View>
                        )}

                        <View
                            style={{
                                flexDirection: 'row',
                                marginTop: 20,
                                marginBottom: (insets.bottom ?? 0) + 8,
                            }}>
                            <Pressable
                                style={{
                                    flex: 1,
                                    height: 46,
                                    borderRadius: 12,
                                    borderWidth: 1,
                                    borderColor: COLORS.primary,
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    marginRight: 8,
                                    backgroundColor: '#FFFFFF',
                                }}
                                onPress={handleQuickChat}>
                                <Text
                                    style={{
                                        color: COLORS.primary,
                                        fontWeight: '700',
                                    }}>
                                    Chat
                                </Text>
                            </Pressable>
                            <Pressable
                                style={{
                                    flex: 1,
                                    height: 46,
                                    borderRadius: 12,
                                    backgroundColor: COLORS.greenStrong,
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    marginLeft: 8,
                                }}
                                onPress={handleHireNow}>
                                <Text
                                    style={{
                                        color: '#FFFFFF',
                                        fontWeight: '800',
                                    }}>
                                    Thuê ngay
                                </Text>
                            </Pressable>
                        </View>
                    </Animated.View>
                </View>
            )}

            {/* POST JOB MODAL */}
            <Modal
                visible={showPostJob}
                animationType="slide"
                onRequestClose={() => setShowPostJob(false)}>
                <SafeAreaView style={{ flex: 1, backgroundColor: '#FFFFFF' }}>
                    <View style={{ flex: 1, paddingHorizontal: 16, paddingTop: 8 }}>
                        {/* Header */}
                        <View
                            style={{
                                flexDirection: 'row',
                                alignItems: 'center',
                                marginBottom: 16,
                            }}>
                            <Pressable
                                onPress={() => setShowPostJob(false)}
                                hitSlop={10}
                                style={{ paddingRight: 8, paddingVertical: 4 }}>
                                <Icon
                                    name="chevron-left"
                                    size={22}
                                    color={COLORS.text}
                                />
                            </Pressable>
                            <Text
                                style={{
                                    fontSize: 20,
                                    fontWeight: '800',
                                    color: COLORS.text,
                                }}>
                                Đăng việc
                            </Text>
                        </View>

                        <ScrollView
                            style={{ flex: 1 }}
                            keyboardShouldPersistTaps="handled"
                            showsVerticalScrollIndicator={false}>
                            <View style={{ marginBottom: 12 }}>
                                <Label>Tiêu đề công việc *</Label>
                                <Field
                                    value={title}
                                    onChangeText={setTitle}
                                    placeholder="VD: Cần thiết kế logo cho quán cafe"
                                />
                            </View>

                            <View style={{ marginBottom: 12 }}>
                                <Label>Mô tả chi tiết *</Label>
                                <Field
                                    value={desc}
                                    onChangeText={setDesc}
                                    placeholder="Mô tả rõ yêu cầu, deadline..."
                                    multiline
                                />
                            </View>

                            <View style={{ marginBottom: 12 }}>
                                <Label>Danh mục</Label>
                                <ScrollView
                                    horizontal
                                    showsHorizontalScrollIndicator={false}>
                                    {CATEGORIES.map(c => {
                                        const active = c === category;
                                        return (
                                            <Pressable
                                                key={c}
                                                onPress={() =>
                                                    setCategory(c as Category)
                                                }
                                                style={{
                                                    paddingHorizontal: 12,
                                                    paddingVertical: 6,
                                                    borderRadius: 999,
                                                    borderWidth: 1,
                                                    borderColor: active
                                                        ? COLORS.primary
                                                        : COLORS.border,
                                                    marginRight: 8,
                                                    backgroundColor: active
                                                        ? '#ECFDF5'
                                                        : '#FFFFFF',
                                                }}>
                                                <Text
                                                    style={{
                                                        fontSize: 12,
                                                        color: active
                                                            ? COLORS.primary
                                                            : COLORS.muted,
                                                        fontWeight: active
                                                            ? '700'
                                                            : '400',
                                                    }}>
                                                    {c}
                                                </Text>
                                            </Pressable>
                                        );
                                    })}
                                </ScrollView>
                            </View>

                            <View style={{ marginBottom: 12 }}>
                                <Label>Ngân sách dự kiến (VND)</Label>
                                <Field
                                    value={budget}
                                    onChangeText={setBudget}
                                    placeholder="VD: 1.000.000"
                                    keyboardType="numeric"
                                />
                            </View>

                            <View style={{ marginBottom: 12 }}>
                                <Label>Tỉnh / Thành phố *</Label>
                                <Field
                                    value={city}
                                    onChangeText={setCity}
                                    placeholder="VD: Hồ Chí Minh"
                                />
                            </View>

                            <View style={{ marginBottom: 12 }}>
                                <Label>Kỹ năng mong muốn (phân tách bằng dấu phẩy)</Label>
                                <Field
                                    value={skillsText}
                                    onChangeText={setSkillsText}
                                    placeholder="VD: React Native, Firebase, UI/UX"
                                />
                            </View>

                            <View style={{ marginBottom: 12 }}>
                                <Label>Tên người đăng</Label>
                                <Field
                                    value={posterName}
                                    onChangeText={setPosterName}
                                    placeholder="Tên của bạn"
                                />
                            </View>

                            <View style={{ marginBottom: 12 }}>
                                <Label>Thông tin liên hệ</Label>
                                <Field
                                    value={posterContact}
                                    onChangeText={setPosterContact}
                                    placeholder="Email / SĐT liên hệ"
                                />
                            </View>

                            <View style={{ marginBottom: 20 }}>
                                <Label>Địa chỉ chi tiết (không bắt buộc)</Label>
                                <Field
                                    value={posterAddress}
                                    onChangeText={setPosterAddress}
                                    placeholder="Địa chỉ cụ thể (nếu có)"
                                />
                            </View>

                            <Pressable
                                onPress={submitPostJob}
                                style={{
                                    height: 52,
                                    borderRadius: 14,
                                    backgroundColor: COLORS.primary,
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    marginBottom: (insets.bottom ?? 0) + 16,
                                }}>
                                <Text
                                    style={{
                                        color: '#FFFFFF',
                                        fontWeight: '800',
                                    }}>
                                    Đăng việc
                                </Text>
                            </Pressable>
                        </ScrollView>
                    </View>
                </SafeAreaView>
            </Modal>

            {/* WALLET MODAL */}
            <Modal
                visible={showWalletModal}
                animationType="slide"
                onRequestClose={() => setShowWalletModal(false)}>
                <SafeAreaView style={{ flex: 1, backgroundColor: '#FFFFFF' }}>
                    <View style={{ flex: 1, paddingHorizontal: 16, paddingTop: 8 }}>
                        {/* Header */}
                        <View
                            style={{
                                flexDirection: 'row',
                                alignItems: 'center',
                                marginBottom: 16,
                            }}>
                            <Pressable
                                onPress={() => setShowWalletModal(false)}
                                hitSlop={10}
                                style={{ paddingRight: 8, paddingVertical: 4 }}>
                                <Icon
                                    name="chevron-left"
                                    size={22}
                                    color={COLORS.text}
                                />
                            </Pressable>
                            <Text
                                style={{
                                    fontSize: 20,
                                    fontWeight: '800',
                                    color: COLORS.text,
                                }}>
                                Ví SkillHub
                            </Text>
                        </View>

                        {!user && (
                            <View
                                style={{
                                    padding: 12,
                                    borderRadius: 12,
                                    backgroundColor: '#FEF2F2',
                                    borderWidth: 1,
                                    borderColor: '#FCA5A5',
                                    marginBottom: 16,
                                }}>
                                <Text
                                    style={{
                                        color: COLORS.danger,
                                        fontWeight: '700',
                                        marginBottom: 4,
                                    }}>
                                    Bạn chưa đăng nhập
                                </Text>
                                <Text style={{ color: COLORS.muted, fontSize: 13 }}>
                                    Hãy đăng nhập để sử dụng chức năng ví (nạp / rút /
                                    chuyển tiền).
                                </Text>
                            </View>
                        )}

                        {/* Balance card */}
                        <View
                            style={{
                                borderRadius: 22,
                                padding: 16,
                                backgroundColor: COLORS.primary,
                                marginBottom: 16,
                            }}>
                            <Text
                                style={{
                                    color: '#D1FAE5',
                                    fontSize: 13,
                                    marginBottom: 4,
                                }}>
                                Số dư hiện tại
                            </Text>
                            <Text
                                style={{
                                    color: '#FFFFFF',
                                    fontSize: 28,
                                    fontWeight: '800',
                                }}>
                                {loadingBalance ? 'Đang tải...' : formatMoney(balance)}
                            </Text>
                            {user?.email && (
                                <Text
                                    style={{
                                        marginTop: 6,
                                        color: '#E5E7EB',
                                        fontSize: 12,
                                    }}>
                                    Tài khoản: {user.email}
                                </Text>
                            )}
                        </View>

                        <ScrollView
                            style={{ flex: 1 }}
                            keyboardShouldPersistTaps="handled"
                            showsVerticalScrollIndicator={false}>
                            {/* mode Nạp / Rút / Chuyển */}
                            <View
                                style={{
                                    flexDirection: 'row',
                                    borderRadius: 999,
                                    borderWidth: 1,
                                    borderColor: COLORS.border,
                                    padding: 3,
                                    marginBottom: 16,
                                    backgroundColor: '#F9FAFB',
                                }}>
                                <Pressable
                                    onPress={() => setWalletMode('deposit')}
                                    style={{
                                        flex: 1,
                                        height: 40,
                                        borderRadius: 999,
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        backgroundColor:
                                            walletMode === 'deposit'
                                                ? '#FFFFFF'
                                                : 'transparent',
                                    }}>
                                    <Text
                                        style={{
                                            color:
                                                walletMode === 'deposit'
                                                    ? COLORS.primary
                                                    : COLORS.muted,
                                            fontWeight: '700',
                                        }}>
                                        Nạp tiền
                                    </Text>
                                </Pressable>
                                <Pressable
                                    onPress={() => setWalletMode('withdraw')}
                                    style={{
                                        flex: 1,
                                        height: 40,
                                        borderRadius: 999,
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        backgroundColor:
                                            walletMode === 'withdraw'
                                                ? '#FFFFFF'
                                                : 'transparent',
                                    }}>
                                    <Text
                                        style={{
                                            color:
                                                walletMode === 'withdraw'
                                                    ? COLORS.primary
                                                    : COLORS.muted,
                                            fontWeight: '700',
                                        }}>
                                        Rút tiền
                                    </Text>
                                </Pressable>
                                <Pressable
                                    onPress={() => setWalletMode('transfer')}
                                    style={{
                                        flex: 1,
                                        height: 40,
                                        borderRadius: 999,
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        backgroundColor:
                                            walletMode === 'transfer'
                                                ? '#FFFFFF'
                                                : 'transparent',
                                    }}>
                                    <Text
                                        style={{
                                            color:
                                                walletMode === 'transfer'
                                                    ? COLORS.primary
                                                    : COLORS.muted,
                                            fontWeight: '700',
                                        }}>
                                        Chuyển tiền
                                    </Text>
                                </Pressable>
                            </View>

                            {/* Số tiền */}
                            <View style={{ marginBottom: 12 }}>
                                <Text
                                    style={{
                                        fontSize: 12,
                                        color: COLORS.muted,
                                        marginBottom: 6,
                                    }}>
                                    Số tiền (VND)
                                </Text>
                                <View
                                    style={{
                                        flexDirection: 'row',
                                        alignItems: 'center',
                                        borderWidth: 1,
                                        borderColor: COLORS.border,
                                        borderRadius: 12,
                                        paddingHorizontal: 12,
                                        backgroundColor: COLORS.fieldBg,
                                        height: 52,
                                    }}>
                                    <Icon
                                        name={
                                            walletMode === 'deposit'
                                                ? 'arrow-down-circle'
                                                : walletMode === 'withdraw'
                                                    ? 'arrow-up-circle'
                                                    : 'repeat'
                                        }
                                        size={18}
                                        color={COLORS.muted}
                                        style={{ marginRight: 8 }}
                                    />
                                    <TextInput
                                        value={walletAmount}
                                        onChangeText={setWalletAmount}
                                        placeholder="Nhập số tiền..."
                                        placeholderTextColor="#9CA3AF"
                                        keyboardType="numeric"
                                        style={{
                                            flex: 1,
                                            fontSize: 16,
                                            color: COLORS.text,
                                        }}
                                    />
                                </View>
                                {(walletMode === 'withdraw' ||
                                    walletMode === 'transfer') && (
                                    <Text
                                        style={{
                                            marginTop: 4,
                                            fontSize: 11,
                                            color: COLORS.muted,
                                        }}>
                                        Số dư khả dụng: {formatMoney(balance)}
                                    </Text>
                                )}
                            </View>

                            {/* Thông tin ngân hàng khi Rút tiền */}
                            {walletMode === 'withdraw' && (
                                <View style={{ marginBottom: 12 }}>
                                    <Text
                                        style={{
                                            fontSize: 12,
                                            color: COLORS.muted,
                                            marginBottom: 6,
                                        }}>
                                        Ngân hàng nhận tiền
                                    </Text>
                                    <TextInput
                                        value={bankName}
                                        onChangeText={setBankName}
                                        placeholder="VD: Vietcombank, Techcombank..."
                                        placeholderTextColor="#9CA3AF"
                                        style={{
                                            borderWidth: 1,
                                            borderColor: COLORS.border,
                                            borderRadius: 12,
                                            paddingHorizontal: 12,
                                            paddingVertical: 10,
                                            color: COLORS.text,
                                            backgroundColor: COLORS.fieldBg,
                                            marginBottom: 8,
                                        }}
                                    />
                                    <TextInput
                                        value={bankAccountNumber}
                                        onChangeText={setBankAccountNumber}
                                        placeholder="Số tài khoản ngân hàng"
                                        placeholderTextColor="#9CA3AF"
                                        keyboardType="number-pad"
                                        style={{
                                            borderWidth: 1,
                                            borderColor: COLORS.border,
                                            borderRadius: 12,
                                            paddingHorizontal: 12,
                                            paddingVertical: 10,
                                            color: COLORS.text,
                                            backgroundColor: COLORS.fieldBg,
                                            marginBottom: 8,
                                        }}
                                    />
                                    <TextInput
                                        value={bankAccountHolder}
                                        onChangeText={setBankAccountHolder}
                                        placeholder="Tên chủ tài khoản"
                                        placeholderTextColor="#9CA3AF"
                                        style={{
                                            borderWidth: 1,
                                            borderColor: COLORS.border,
                                            borderRadius: 12,
                                            paddingHorizontal: 12,
                                            paddingVertical: 10,
                                            color: COLORS.text,
                                            backgroundColor: COLORS.fieldBg,
                                        }}
                                    />
                                    <Text
                                        style={{
                                            marginTop: 4,
                                            fontSize: 11,
                                            color: COLORS.muted,
                                        }}>
                                        Thông tin này dùng để rút tiền từ ví SkillHub về tài
                                        khoản ngân hàng của bạn (xử lý thật sẽ do backend gọi
                                        API ngân hàng / cổng thanh toán).
                                    </Text>
                                </View>
                            )}

                            {/* Số tài khoản người nhận (chỉ khi Chuyển) */}
                            {walletMode === 'transfer' && (
                                <View style={{ marginBottom: 12 }}>
                                    <Text
                                        style={{
                                            fontSize: 12,
                                            color: COLORS.muted,
                                            marginBottom: 6,
                                        }}>
                                        Số tài khoản người nhận
                                    </Text>
                                    <TextInput
                                        value={walletTargetAccount}
                                        onChangeText={setWalletTargetAccount}
                                        placeholder="Nhập số tài khoản ví SkillHub"
                                        placeholderTextColor="#9CA3AF"
                                        keyboardType="number-pad"
                                        style={{
                                            borderWidth: 1,
                                            borderColor: COLORS.border,
                                            borderRadius: 12,
                                            paddingHorizontal: 12,
                                            paddingVertical: 10,
                                            color: COLORS.text,
                                            backgroundColor: COLORS.fieldBg,
                                        }}
                                    />
                                    <Text
                                        style={{
                                            marginTop: 4,
                                            fontSize: 11,
                                            color: COLORS.muted,
                                        }}>
                                        Hệ thống sẽ tìm ví theo field
                                        "accountNumber" trong collection "wallets".
                                    </Text>
                                </View>
                            )}

                            {/* Ghi chú */}
                            <View style={{ marginBottom: 16 }}>
                                <Text
                                    style={{
                                        fontSize: 12,
                                        color: COLORS.muted,
                                        marginBottom: 6,
                                    }}>
                                    Ghi chú (tùy chọn)
                                </Text>
                                <TextInput
                                    value={walletNote}
                                    onChangeText={setWalletNote}
                                    placeholder={
                                        walletMode === 'deposit'
                                            ? 'VD: Nạp tiền từ Momo / ngân hàng...'
                                            : walletMode === 'withdraw'
                                                ? 'VD: Rút về tài khoản ngân hàng...'
                                                : 'VD: Thanh toán cho freelancer...'
                                    }
                                    placeholderTextColor="#9CA3AF"
                                    multiline
                                    numberOfLines={3}
                                    style={{
                                        borderWidth: 1,
                                        borderColor: COLORS.border,
                                        borderRadius: 12,
                                        paddingHorizontal: 12,
                                        paddingVertical: 10,
                                        minHeight: 72,
                                        color: COLORS.text,
                                        backgroundColor: COLORS.fieldBg,
                                        textAlignVertical: 'top',
                                    }}
                                />
                            </View>

                            {/* Submit */}
                            <Pressable
                                disabled={!walletCanSubmit || !user || walletSubmitting}
                                onPress={handleWalletSubmit}
                                style={{
                                    height: 52,
                                    borderRadius: 14,
                                    backgroundColor:
                                        !user || !walletCanSubmit || walletSubmitting
                                            ? '#9CA3AF'
                                            : COLORS.green,
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    flexDirection: 'row',
                                    marginBottom: 20,
                                }}>
                                <Icon
                                    name={
                                        walletMode === 'deposit'
                                            ? 'download'
                                            : walletMode === 'withdraw'
                                                ? 'upload'
                                                : 'send'
                                    }
                                    size={18}
                                    color="#FFFFFF"
                                    style={{ marginRight: 8 }}
                                />
                                <Text
                                    style={{
                                        color: '#FFFFFF',
                                        fontWeight: '800',
                                    }}>
                                    {walletSubmitting
                                        ? 'Đang xử lý...' : walletMode === 'deposit' ? 'Xác nhận nạp tiền' : walletMode === 'withdraw' ? 'Xác nhận rút tiền' : 'Xác nhận chuyển tiền'}
                                </Text>
                            </Pressable>

                            {/* Error ví */}
                            {!!walletError && (
                                <View
                                    style={{
                                        padding: 10,
                                        borderRadius: 12,
                                        backgroundColor: '#FEF2F2',
                                        borderWidth: 1,
                                        borderColor: '#FCA5A5',
                                        marginBottom: 10,
                                    }}>
                                    <Text
                                        style={{
                                            color: COLORS.danger,
                                            fontSize: 12,
                                        }}>
                                        {walletError}
                                    </Text>
                                </View>
                            )}

                            {/* Lịch sử */}
                            <Text
                                style={{
                                    fontSize: 14,
                                    fontWeight: '700',
                                    color: COLORS.text,
                                    marginBottom: 6,
                                }}>
                                Lịch sử giao dịch
                            </Text>
                            {loadingTxs ? (
                                <Text style={{ color: COLORS.muted, marginBottom: 16 }}>
                                    Đang tải lịch sử...
                                </Text>
                            ) : txs.length === 0 ? (
                                <Text style={{ color: COLORS.muted, marginBottom: 16 }}>
                                    Chưa có giao dịch nào.
                                </Text>
                            ) : (<View
                                    style={{
                                        borderWidth: 1,
                                        borderColor: COLORS.border,
                                        borderRadius: 16,
                                        paddingHorizontal: 12,
                                        paddingVertical: 4,
                                        marginBottom: (insets.bottom ?? 0) + 10,
                                        backgroundColor: '#F9FAFB',
                                    }}>
                                    <FlatList
                                        scrollEnabled={false}
                                        data={txs}
                                        keyExtractor={it => it.id}
                                        renderItem={renderWalletTxItem}
                                        ItemSeparatorComponent={() => null}
                                    />
                                </View>
                            )}
                        </ScrollView>
                    </View>
                </SafeAreaView>
            </Modal>
        </View>
    );
};
export default MyJobsTab;
