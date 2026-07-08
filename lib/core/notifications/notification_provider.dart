import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'notification_service.dart';

part 'notification_provider.g.dart';

@Riverpod(keepAlive: true)
INotificationService notificationService(Ref ref) => const NotificationService();
