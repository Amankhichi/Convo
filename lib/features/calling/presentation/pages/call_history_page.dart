import 'package:convo/app/config/api_config.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:convo/features/calling/domain/entities/call_log_entity.dart';
import 'package:convo/features/calling/domain/entities/call_status.dart';
import 'package:convo/features/calling/domain/repositories/call_repository.dart';
import 'package:convo/features/calling/presentation/bloc/call_bloc.dart';
import 'package:convo/features/calling/presentation/bloc/call_event.dart';
import 'package:convo/features/calling/presentation/pages/call_page.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CallHistoryPage extends StatefulWidget {
  const CallHistoryPage({super.key});

  @override
  State<CallHistoryPage> createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage> {
  bool _isLoading = true;
  List<CallLogEntity> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final logs = await sl<CallRepository>().fetchCallHistory();
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _logs = sl<CallRepository>().getCallLogs();
          _isLoading = false;
        });
      }
    }
  }

  void _initiateCall(CallLogEntity log) {
    context.read<CallBloc>().add(InitiateOutgoingCallEvent(
          targetUserId: log.targetUserId,
          targetName: log.targetUserName,
          targetAvatar: log.targetUserImage,
          callType: CallType.voice,
        ));

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CallPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text("Call History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _logs.isEmpty
              ? const Center(
                  child: Text(
                    "No call history yet",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _logs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _logs[index];
                      return _buildCallLogTile(item);
                    },
                  ),
                ),
    );
  }

  Widget _buildCallLogTile(CallLogEntity item) {
    final sanitizedImage = ApiConfig.sanitizeUrl(item.targetUserImage);
    final isIncoming = item.direction.toUpperCase() == 'INCOMING';
    final isMissed = item.direction.toUpperCase() == 'MISSED' ||
        item.direction.toUpperCase() == 'REJECTED';

    String formattedDate = item.timestamp;
    try {
      final dt = DateTime.parse(item.timestamp).toLocal();
      formattedDate = DateFormat('MMM d, h:mm a').format(dt);
    } catch (_) {}

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary,
        backgroundImage: sanitizedImage.isNotEmpty ? NetworkImage(sanitizedImage) : null,
        child: sanitizedImage.isEmpty
            ? Text(
                item.targetUserName.isNotEmpty ? item.targetUserName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(
        item.targetUserName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Row(
        children: [
          Icon(
            isIncoming
                ? (isMissed ? Icons.call_missed : Icons.call_received)
                : Icons.call_made,
            size: 16,
            color: isMissed ? Colors.red : (isIncoming ? Colors.green : Colors.blue),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "$formattedDate ${item.duration.isNotEmpty ? '• ${item.duration}' : ''}",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.call_outlined, color: AppColors.primary),
        onPressed: () => _initiateCall(item),
      ),
    );
  }
}
