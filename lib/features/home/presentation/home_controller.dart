import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/account/data/account_repository.dart';
import 'package:palakat/features/presentation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data_sources/data_sources.dart';
import '../../../core/data_sources/network/dio_client.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  late AccountRepository _accountRepository;

  @override
  HomeState build() {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _checkAndGetToken();
    });

    checkSignedInAccount();

    //check if there user currently signed in
    _accountRepository = ref.read(accountRepositoryProvider);

    return HomeState(pageController: PageController(initialPage: 0));
  }

  void checkSignedInAccount() async {
    final result = await _accountRepository.checkSignedInAccount();

    result.when(
      onSuccess: (data) {
        if (data != null) {
        // a signed account is exists
        }

        //things to do if no signed in account

      },
      onFailure: (failure) {
        // things to do related to presentation layer or UI if error occurred

      },
    );
  }

  /// So otomatis di handle tiap ad error unathorized access token di tiap request dari dio
  // Future<void> _checkAndGetToken() async {
  //   try {
  //     final hiveService = ref.read(hiveServiceProvider.notifier);
  //
  //     final auth = hiveService.getAuth();
  //
  //     if (auth == null || auth.accessToken.isEmpty) {
  //       dev.log(
  //         "[HOME CONTROLLER] Token tidak ditemukan, mengambil token baru...",
  //       );
  //       await _getNewToken();
  //     } else {
  //       dev.log("[HOME CONTROLLER] Token ditemukan");
  //     }
  //   } catch (e) {
  //     dev.log("[HOME CONTROLLER] Error checking token");
  //   }
  // }
  //
  // Future<void> _getNewToken() async {
  //   try {
  //     final dioClient = ref.read(dioClientProvider);
  //
  //     final username = dotenv.env['x-username'];
  //     final password = dotenv.env['x-password'];
  //
  //     final response = await dioClient.get<Map<String, dynamic>>(
  //       Endpoint.signing,
  //       options: Options(
  //         headers: {
  //           'accept': 'application/json',
  //           'x-username': username,
  //           'x-password': password,
  //         },
  //       ),
  //     );
  //
  //     if (response != null && response['data'] != null) {
  //       final token = response['data'] as String;
  //
  //       final authData = AuthData(accessToken: token, refreshToken: token);
  //
  //       final hiveService = ref.read(hiveServiceProvider.notifier);
  //       await hiveService.saveAuth(authData);
  //
  //       dev.log("[HOME CONTROLLER] Token successfully obtained and saved");
  //     } else {
  //       throw Exception(
  //         "Invalid response from token endpoint: response is null or missing 'data' field",
  //       );
  //     }
  //   } catch (e) {
  //     dev.log("[HOME CONTROLLER] Error getting new token");
  //     rethrow;
  //   }
  // }
  //
  // bool get isAuthenticated {
  //   final hiveService = ref.read(hiveServiceProvider.notifier);
  //   final auth = hiveService.getAuth();
  //   return auth != null && auth.accessToken.isNotEmpty;
  // }

  void navigateTo(int index) async {
    state.pageController.jumpToPage(index);
    state = state.copyWith(selectedBottomNavIndex: index);
  }

  void setCurrentBackPressTime(DateTime value) {
    state = state.copyWith(currentBackPressTime: value);
  }
}
