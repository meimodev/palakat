import 'dart:math';
import 'package:flutter/material.dart';

class PaginationBar extends StatefulWidget {
  final int total;
  final int pageSize;
  final int page;
  final ValueChanged<int> onPageSizeChanged;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const PaginationBar({
    super.key,
    required this.total,
    required this.pageSize,
    required this.page,
    required this.onPageSizeChanged,
    required this.onPageChanged,
    this.onPrev,
    this.onNext,
  });

  @override
  State<PaginationBar> createState() => _PaginationBarState();
}

class _PaginationBarState extends State<PaginationBar> {
  int pageSize = 0;
  List<int> defaultPageSizes = [10, 20, 30, 50, 100];

  @override
  void initState() {
    super.initState();
    if (widget.pageSize != 0) {
      if (!defaultPageSizes.contains(widget.pageSize)) {
        throw ArgumentError(
          'pageSize must be one of ${defaultPageSizes.join(", ")}',
        );
      }
      pageSize = widget.pageSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate pageCount internally
    final pageCount = widget.total == 0
        ? 1
        : (widget.total / widget.pageSize).ceil();

    final showingCount = min(widget.page * widget.pageSize, widget.total);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Text(
            'Showing $showingCount of ${widget.total} rows',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text('Rows per page', style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: pageSize,
            items: defaultPageSizes
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      '$e',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                pageSize = v ?? 0;
              });
              if (v != null) widget.onPageSizeChanged(v);
            },
          ),
          const SizedBox(width: 16),
          Text('Page', style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: widget.page.clamp(1, pageCount),
            items: [for (int i = 1; i <= pageCount; i++) i]
                .map(
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(
                      '$i',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                widget.onPageChanged(value);
              }
            },
          ),
          const SizedBox(width: 8),
          Text('of $pageCount', style: theme.textTheme.bodySmall),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: widget.onPrev,
            child: const Text('Previous'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: widget.onNext, child: const Text('Next')),
        ],
      ),
    );
  }
}
