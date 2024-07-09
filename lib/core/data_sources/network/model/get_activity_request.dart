import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class GetActivitiesRequest {
  final String churchSerial;
  final DateTimeRange? activityDateRange;
  final DateTimeRange? publishDateRange;
  final ActivityType? activityType;
  final String? activitySerial;

  GetActivitiesRequest( {
    required this.churchSerial,
    this.activityDateRange,
    this.publishDateRange,
    this.activityType,
    this.activitySerial,
  });



}
