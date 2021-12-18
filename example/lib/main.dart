/*
 * Tencent is pleased to support the open source community by making
 * Ohmmkv available.
 *
 * Copyright (C) 2020 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ohmmkv/ohmmkv.dart';
import 'package:ohmmkv_example/logger.dart';

void main() async {
  // must wait for Ohmmkv to finish initialization
  final rootDir = await Ohmmkv.initialize();
  Slog.d('Ohmmkv for flutter with rootDir = $rootDir');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ohmmkv Plugin example app'),
        ),
        body: Center(
            child: Column(children: <Widget>[
          Text('Ohmmkv Version: ${Ohmmkv.version}\n'),
          TextButton(
              onPressed: () {
                functionalTest();
              },
              child: const Text('Functional Test', style: TextStyle(fontSize: 18))),
          TextButton(
              onPressed: () {
                testReKey();
              },
              child: const Text('Encryption Test', style: TextStyle(fontSize: 18))),
          TextButton(
              onPressed: () {
                testBackup();
                testRestore();
              },
              child: const Text('Backup & Restore Test', style: TextStyle(fontSize: 18))),
        ])),
      ),
    );
  }

  void functionalTest() {
    /* Note: If you come across to failing to load defaultOhmmkv() on Android after upgrading Flutter from 1.20+ to 2.0+,
     * you can try passing this encryption key '\u{2}U' instead.
     * var Ohmmkv = Ohmmkv.defaultOhmmkv(cryptKey: '\u{2}U');
     */
    var mmkv = Ohmmkv.defaultMMKV();
    mmkv.encodeBool('bool', true);
    Slog.d('bool = ${mmkv.decodeBool('bool')}');

    mmkv.encodeInt32('int32', (1 << 31) - 1);
    Slog.d('max int32 = ${mmkv.decodeInt32('int32')}');

    mmkv.encodeInt32('int32', 0 - (1 << 31));
    Slog.d('min int32 = ${mmkv.decodeInt32('int32')}');

    mmkv.encodeInt('int', (1 << 63) - 1);
    Slog.d('max int = ${mmkv.decodeInt('int')}');

    mmkv.encodeInt('int', 0 - (1 << 63));
    Slog.d('min int = ${mmkv.decodeInt('int')}');

    mmkv.encodeDouble('double', double.maxFinite);
    Slog.d('max double = ${mmkv.decodeDouble('double')}');

    mmkv.encodeDouble('double', double.minPositive);
    Slog.d('min positive double = ${mmkv.decodeDouble('double')}');

    String str = 'Hello dart from Ohmmkv';
    mmkv.encodeString('string', str);
    Slog.d('string = ${mmkv.decodeString('string')}');

    mmkv.encodeString('string', '');
    Slog.d('empty string = ${mmkv.decodeString('string')}');
    Slog.d('contains "string": ${mmkv.containsKey('string')}');

    mmkv.encodeString('string', null);
    Slog.d('null string = ${mmkv.decodeString('string')}');
    Slog.d('contains "string": ${mmkv.containsKey('string')}');

    str += ' with bytes';
    var bytes = MMBuffer.fromList(Utf8Encoder().convert(str))!;
    mmkv.encodeBytes('bytes', bytes);
    bytes.destroy();
    bytes = mmkv.decodeBytes('bytes')!;
    Slog.d('bytes = ${Utf8Decoder().convert(bytes.asList()!)}');
    bytes.destroy();

    Slog.d('contains "bool": ${mmkv.containsKey('bool')}');
    mmkv.removeValue('bool');
    Slog.d('after remove, contains "bool": ${mmkv.containsKey('bool')}');
    mmkv.removeValues(['int32', 'int']);
    Slog.d('all keys: ${mmkv.allKeys}');

    mmkv.trim();
    mmkv.clearMemoryCache();
    Slog.d('all keys: ${mmkv.allKeys}');
    mmkv.clearAll();
    Slog.d('all keys: ${mmkv.allKeys}');
  }

  Ohmmkv testOhmmkv(String mmapID, String? cryptKey, bool decodeOnly, String? rootPath) {
    final mmkv = Ohmmkv(mmapID, cryptKey: cryptKey, rootDir: rootPath);

    if (!decodeOnly) {
      mmkv.encodeBool('bool', true);
    }
    Slog.d('bool = ${mmkv.decodeBool('bool')}');

    if (!decodeOnly) {
      mmkv.encodeInt32('int32', (1 << 31) - 1);
    }
    Slog.d('max int32 = ${mmkv.decodeInt32('int32')}');

    if (!decodeOnly) {
      mmkv.encodeInt32('int32', 0 - (1 << 31));
    }
    Slog.d('min int32 = ${mmkv.decodeInt32('int32')}');

    if (!decodeOnly) {
      mmkv.encodeInt('int', (1 << 63) - 1);
    }
    Slog.d('max int = ${mmkv.decodeInt('int')}');

    if (!decodeOnly) {
      mmkv.encodeInt('int', 0 - (1 << 63));
    }
    Slog.d('min int = ${mmkv.decodeInt('int')}');

    if (!decodeOnly) {
      mmkv.encodeDouble('double', double.maxFinite);
    }
    Slog.d('max double = ${mmkv.decodeDouble('double')}');

    if (!decodeOnly) {
      mmkv.encodeDouble('double', double.minPositive);
    }
    Slog.d('min positive double = ${mmkv.decodeDouble('double')}');

    String str = 'Hello dart from Ohmmkv';
    if (!decodeOnly) {
      mmkv.encodeString('string', str);
    }
    Slog.d('string = ${mmkv.decodeString('string')}');

    str += ' with bytes';
    var bytes = MMBuffer.fromList(const Utf8Encoder().convert(str))!;
    if (!decodeOnly) {
      mmkv.encodeBytes('bytes', bytes);
    }
    bytes.destroy();
    bytes = mmkv.decodeBytes('bytes')!;
    Slog.d('bytes = ${const Utf8Decoder().convert(bytes.asList()!)}');
    bytes.destroy();

    Slog.d('contains "bool": ${mmkv.containsKey('bool')}');
    mmkv.removeValue('bool');
    Slog.d('after remove, contains "bool": ${mmkv.containsKey('bool')}');
    mmkv.removeValues(['int32', 'int']);
    Slog.d('all keys: ${mmkv.allKeys}');

    return mmkv;
  }

  void testReKey() {
    final mmapID = 'testAES_reKey1';
    Ohmmkv kv = testOhmmkv(mmapID, null, false, null);

    kv.reKey("Key_seq_1");
    kv.clearMemoryCache();
    testOhmmkv(mmapID, 'Key_seq_1', true, null);

    kv.reKey('Key_seq_2');
    kv.clearMemoryCache();
    testOhmmkv(mmapID, 'Key_seq_2', true, null);

    kv.reKey(null);
    kv.clearMemoryCache();
    testOhmmkv(mmapID, null, true, null);
  }

  void testBackup() {
    final rootDir = FileSystemEntity.parentOf(Ohmmkv.rootDir);
    var backupRootDir = rootDir + "/Ohmmkv_backup_3";
    String mmapID = "test/AES";
    String cryptKey = "Tencent Ohmmkv";
    String otherDir = rootDir + "/Ohmmkv_3";
    testOhmmkv(mmapID, cryptKey, false, otherDir);

    final ret = Ohmmkv.backupOneToDirectory(mmapID, backupRootDir, rootDir: otherDir);
    Slog.d('backup one [$mmapID] return: $ret');

    backupRootDir = rootDir + "/Ohmmkv_backup";
    final count = Ohmmkv.backupAllToDirectory(backupRootDir);
    Slog.d("backup all count: $count");
  }

  void testRestore() {
    final rootDir = FileSystemEntity.parentOf(Ohmmkv.rootDir);
    var backupRootDir = rootDir + "/Ohmmkv_backup_3";
    String mmapID = "test/AES";
    String cryptKey = "Tencent Ohmmkv";
    String otherDir = rootDir + "/Ohmmkv_3";

    final kv = Ohmmkv(mmapID, cryptKey: cryptKey, rootDir: otherDir);
    kv.encodeString('test_restore', 'value before restore');
    Slog.d("before restore [${kv.mmapID}] allKeys: ${kv.allKeys}");
    final ret = Ohmmkv.restoreOneMMKVFromDirectory(mmapID, backupRootDir, rootDir: otherDir);
    Slog.d("restore one [${kv.mmapID}] ret = $ret");
    if (ret) {
      Slog.d("after restore [${kv.mmapID}] allKeys: ${kv.allKeys}");
    }

    backupRootDir = rootDir + "/Ohmmkv_backup";
    final count = Ohmmkv.restoreAllFromDirectory(backupRootDir);
    Slog.d("restore all count $count");
    if (count > 0) {
      var mmkv = Ohmmkv.defaultMMKV();
      Slog.d("check on restore file[${mmkv.mmapID}] allKeys: ${mmkv.allKeys}");

      mmkv = Ohmmkv('testAES_reKey1');
      Slog.d("check on restore file[${mmkv.mmapID}] allKeys: ${mmkv.allKeys}");
    }
  }
}
