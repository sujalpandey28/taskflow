import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/presentation/providers/notifications_provider.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;

  const NotificationsScreen({super.key, required this.userId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color pageBackground = Color(0xFFF6F3FC);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications(widget.userId);
    });
  }

  Future<void> _markAsRead(String notificationId) async {
    await context.read<NotificationProvider>().markAsRead(notificationId);
  }

  Future<void> _deleteNotification(String notificationId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: const Text(
            'Are you sure you want to delete this notification?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await context.read<NotificationProvider>().deleteNotification(
      notificationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: darkText, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: darkText),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount == 0) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: () {
                  provider.markAllAsRead();
                },
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.status == NotificationStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (provider.status == NotificationStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: lightPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 38,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage ?? 'Something went wrong.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: darkText, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        provider.loadNotifications(widget.userId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EmptyNotificationIcon(),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'You’re all caught up!',
                    style: TextStyle(fontSize: 14, color: secondaryText),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () {
              return provider.loadNotifications(widget.userId);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];

                return Card(
                  margin: EdgeInsets.zero,
                  elevation: notification.read ? 1 : 3,
                  shadowColor: Colors.black.withValues(alpha: 0.06),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: notification.read
                          ? const Color(0xFFE2DCEB)
                          : primaryColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    onTap: () {
                      if (!notification.read) {
                        _markAsRead(notification.id);
                      }
                    },
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: notification.read
                            ? const Color(0xFFF0EDF4)
                            : lightPurple,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        notification.read
                            ? Icons.notifications_none_rounded
                            : Icons.notifications_active_rounded,
                        color: notification.read ? secondaryText : primaryColor,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: darkText,
                        fontWeight: notification.read
                            ? FontWeight.w500
                            : FontWeight.w700,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        '${notification.type} • '
                        '${_formatDate(notification.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: secondaryText,
                      ),
                      onSelected: (value) {
                        if (value == 'read') {
                          _markAsRead(notification.id);
                        }

                        if (value == 'delete') {
                          _deleteNotification(notification.id);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'read',
                          child: Row(
                            children: [
                              Icon(Icons.done_rounded, color: primaryColor),
                              SizedBox(width: 8),
                              Text('Mark as read'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _EmptyNotificationIcon extends StatelessWidget {
  const _EmptyNotificationIcon();

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: lightPurple,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(
        Icons.notifications_none_rounded,
        size: 42,
        color: primaryColor,
      ),
    );
  }
}
