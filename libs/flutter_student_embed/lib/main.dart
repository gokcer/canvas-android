import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_student_embed/student_flutter_app.dart';
import 'package:flutter_student_embed/utils/NativeComm.dart';
import 'package:flutter_student_embed/utils/crash_utils.dart';
import 'package:flutter_student_embed/utils/db/db_util.dart';
import 'package:flutter_student_embed/utils/service_locator.dart';

import 'network/utils/api_prefs.dart';

void main() async {
  runZoned<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    NativeComm.init();

    await Future.wait([
      ApiPrefs.init(),
      CrashUtils.init(),
      DbUtil.init(),
    ]);
    setupLocator();

    runApp(StudentFlutterApp());
  }, onError: (error, stacktrace) => CrashUtils.reportCrash(error, stacktrace));
}
