// Copyright (C) 2020 - present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_student_embed/models/planner_item.dart';
import 'package:flutter_student_embed/models/serializers.dart';
import 'package:flutter_student_embed/network/utils/api_prefs.dart';
import 'package:flutter_student_embed/screens/calendar/calendar_widget/calendar_widget.dart';
import 'package:flutter_student_embed/screens/calendar/planner_fetcher.dart';

import 'calendar_day_planner.dart';
import 'calendar_widget/calendar_filter_screen/calendar_filter_list_screen.dart';

class CalendarScreen extends StatefulWidget {
  static const String routeName = 'calendar';

  final DateTime startDate;
  final CalendarView startView;

  // Keys for the deep link parameter map passed in via DashboardScreen
  static final startDateKey = 'startDate';
  static final startViewKey = 'startView';
  final String channelId;

  CalendarScreen({Key key, this.startDate, this.startView = CalendarView.Week, this.channelId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  PlannerFetcher _fetcher;

  CalendarScreenChannel _channel;

  GlobalKey<CalendarWidgetState> _calendarKey = GlobalKey();

  @override
  void initState() {
    _fetcher = PlannerFetcher(userId: ApiPrefs.getUser().id, userDomain: ApiPrefs.getDomain());
    if (widget.channelId != null) {
      _channel = CalendarScreenChannel(
        widget.channelId,
        onTodayClicked: () {
          var now = DateTime.now();
          _calendarKey.currentState.selectDay(
            DateTime(now.year, now.month, now.day),
            dayPagerBehavior: CalendarPageChangeBehavior.jump,
            weekPagerBehavior: CalendarPageChangeBehavior.animate,
            monthPagerBehavior: CalendarPageChangeBehavior.animate,
          );
        },
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CalendarWidget(
        key: _calendarKey,
        fetcher: _fetcher,
        startingDate: widget.startDate,
        startingView: widget.startView,
        onTodaySelected: (isTodaySelected) => _channel?.setIsTodaySelected(isTodaySelected),
        onFilterTap: () async {
          Set<String> currentContexts = await _fetcher.getContexts();
          Set<String> updatedContexts = await showModalBottomSheet(
            context: context,
            builder: (context) => CalendarFilterListScreen(currentContexts),
          );
          // Check if the list changed or not
          if (!SetEquality().equals(currentContexts, updatedContexts)) {
            _fetcher.setContexts(updatedContexts);
          }
        },
        dayBuilder: (BuildContext context, DateTime day) {
          return CalendarDayPlanner(day, _channel);
        },
      ),
    );
  }

  @override
  void dispose() {
    _channel?.dispose();
    super.dispose();
  }
}

class CalendarScreenChannel extends MethodChannel {
  final VoidCallback onTodayClicked;

  CalendarScreenChannel(String channelId, {@required this.onTodayClicked}) : super(channelId) {
    setMethodCallHandler((methodCall) async {
      if (methodCall.method == 'todayClicked') onTodayClicked();
    });
  }

  void dispose() {
    setMethodCallHandler(null);
  }

  void setIsTodaySelected(bool isTodaySelected) => invokeMethod('isTodaySelected', isTodaySelected);

  void nativeRouteToItem(PlannerItem item) {
    var payload = json.encode(serialize<PlannerItem>(item));
    invokeMethod('routeToItem', payload);
  }
}
