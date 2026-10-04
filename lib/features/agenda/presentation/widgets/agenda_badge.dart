import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/agenda_providers.dart';

/// Count of overdue and due-today tasks, shown next to the Agenda navigation
/// item. Renders nothing when there's nothing due.
class AgendaBadge extends ConsumerWidget {
  const AgendaBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(agendaDueCountProvider);
    if (count == 0) return const SizedBox.shrink();
    return Badge.count(count: count);
  }
}
