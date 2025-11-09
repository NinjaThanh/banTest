child: Container(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: (t.avatarUrl?.isNotEmpty ?? false)
                                        ? NetworkImage(t.avatarUrl!)
                                        : const AssetImage('assets/images/Max.png')
                                    as ImageProvider,
                                  ),
                                  title: Text(
                                    t.title?.isNotEmpty == true ? t.title! : 'Unnamed chat',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(timeLabel,
                                          style: const TextStyle(color: Color(0xFF797C7B))),
                                      const SizedBox(height: 6),
                                      if (unreadCount > 0)
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: const Color(0xFF4A4CF0),
                                          child: Text(
                                            '$unreadCount',
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                  onTap: () {

                                  },
                                ),
                              ],
                            ),
                          ),
