import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/socket_service.dart';

class SocketConnectionBanner extends ConsumerStatefulWidget {
  const SocketConnectionBanner({
    super.key,
    required this.child,
    this.blockInteractionWhenNotConnected = true,
    this.getSocket = _defaultGetSocket,
  });

  final Widget? child;
  final bool blockInteractionWhenNotConnected;
  final SocketService Function(WidgetRef ref) getSocket;

  static SocketService _defaultGetSocket(WidgetRef ref) =>
      ref.read(socketServiceProvider);

  @override
  ConsumerState<SocketConnectionBanner> createState() =>
      _SocketConnectionBannerState();
}

class _SocketConnectionBannerState extends ConsumerState<SocketConnectionBanner>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _connect();
    });
  }

  @override
  void didUpdateWidget(covariant SocketConnectionBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.getSocket != widget.getSocket) {
      _connect();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _connect();
    }
  }

  void _connect() {
    final socket = widget.getSocket(ref);
    unawaited(socket.connect());
  }

  @override
  Widget build(BuildContext context) {
    final socket = widget.getSocket(ref);

    return ValueListenableBuilder<SocketConnectionStatus>(
      valueListenable: socket.connectionStatusListenable,
      builder: (context, status, _) {
        final rawChild = widget.child ?? const SizedBox.shrink();
        if (status == SocketConnectionStatus.connected) {
          return rawChild;
        }

        final child = widget.blockInteractionWhenNotConnected
            ? AbsorbPointer(
                absorbing: true,
                child: Opacity(opacity: 0.6, child: rawChild),
              )
            : rawChild;

        final colorScheme = Theme.of(context).colorScheme;

        final background = status == SocketConnectionStatus.connecting
            ? colorScheme.tertiaryContainer
            : colorScheme.errorContainer;

        final foreground = status == SocketConnectionStatus.connecting
            ? colorScheme.onTertiaryContainer
            : colorScheme.onErrorContainer;

        final title = status == SocketConnectionStatus.connecting
            ? 'Connecting'
            : 'Offline';

        final subtitle = status == SocketConnectionStatus.connecting
            ? 'Reconnecting to server…'
            : 'No connection. Some actions may fail.';

        return Stack(
          children: [
            child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Material(
                  color: background,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          status == SocketConnectionStatus.connecting
                              ? Icons.wifi_tethering
                              : Icons.wifi_off,
                          color: foreground,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: foreground),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: foreground),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              unawaited(socket.connect());
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: foreground,
                          ),
                          child: const Text('Reconnect'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
