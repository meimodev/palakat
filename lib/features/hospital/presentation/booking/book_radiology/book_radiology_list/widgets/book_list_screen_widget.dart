import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/features/domain.dart';
import 'widgets.dart';

class BookListScreenWidget extends StatelessWidget {
  const BookListScreenWidget({
    super.key,
    required this.categories,
    required this.onChangedHorizontalFilter,
    required this.onTapListItem,
    required this.services,
  });

  final List<BookServiceModel> services;
  final List<String> categories;
  final void Function(String? filter) onChangedHorizontalFilter;
  final void Function() onTapListItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.customWidth(20),
      ),
      child: Column(
        children: [
          Gap.customGapHeight(10),
          FilterChipsHorizontalBarWidget(
            filters: categories,
            onChangedFilter: onChangedHorizontalFilter,
          ),
          Gap.h24,
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Padding(
                  padding: EdgeInsets.only(
                    top: index == 0 ? 0 : BaseSize.h12,
                  ),
                  child: ListCardItemWidget(
                    service: service,
                    onTap: onTapListItem,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
