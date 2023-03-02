import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:palakat/app/widgets/text_field_wrapper.dart';
import 'package:palakat/data/models/song.dart';
import 'package:palakat/shared/shared.dart';

import 'songs_controller.dart';

class SongsScreen extends GetView<SongsController> {
  const SongsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Insets.medium.w,
        right: Insets.medium.w,
        top: Insets.large.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Songs',
            style: TextStyle(
              fontSize: 36.sp,
            ),
          ),
          SizedBox(height: Insets.medium.h),
          TextFieldWrapper(
            textEditingController: controller.tecSearch,
            labelText: "Search from title",
            startIconData: Icons.search_outlined,
            fontColor: Colors.grey,
            onChangeText: controller.onChangeSearchText,
          ),
          SizedBox(height: Insets.small.h),
          Expanded(
            child: Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: controller.songsLoading.isTrue
                    ? const CircularProgressIndicator(color: Palette.primary)
                    : controller.songs.isNotEmpty
                        ? _BuildListSongs(
                            songs: controller.songs,
                            onPressedSongCard: controller.onPressedSongCard,
                          )
                        : _BuildListCategories(
                            categories: controller.songBooks,
                            onPressedCategoryCard:
                                controller.onPressedCategoryCard,
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildListCategories extends StatelessWidget {
  const _BuildListCategories({
    Key? key,
    required this.categories,
    required this.onPressedCategoryCard,
  }) : super(key: key);

  final List<String> categories;
  final void Function(String category) onPressedCategoryCard;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: Insets.small.h,
        crossAxisSpacing: Insets.small.h,
        childAspectRatio: 2,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) => Material(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: () => onPressedCategoryCard(categories[index]),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Insets.small.w,
              vertical: Insets.small.w,
            ),
            child: Center(
              child: Text(
                categories[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildListSongs extends StatelessWidget {
  const _BuildListSongs({
    Key? key,
    required this.songs,
    required this.onPressedSongCard,
  }) : super(key: key);

  final List<Song> songs;
  final void Function(Song song) onPressedSongCard;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: songs.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: Insets.small.h * .25),
        child: SongCard(
          onPressedSongCard: onPressedSongCard,
          song: songs[index],
        ),
      ),
    );
  }
}

class SongCard extends StatelessWidget {
  const SongCard({
    Key? key,
    required this.onPressedSongCard,
    required this.song,
  }) : super(key: key);

  final Song song;
  final void Function(Song song) onPressedSongCard;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.cardBackground,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: () => onPressedSongCard(song),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Insets.small.w,
            vertical: Insets.small.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${song.book.toInitials().toUpperCase()} ${song.entry} ${song.title.toUpperCase()}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '${song.songParts[0].content![0]} ${song.songParts[0].content![1]} ',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
