import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/data/settings.dart';
import 'package:flutter/material.dart';

final FollowUpdater followUpdater = FollowUpdater(settings.follows);

class FollowUpdater extends DataUpdater<List<Follow>> with HostableUpdater {
  Duration get stale => Duration(hours: 4);

  ValueNotifier<Future<List<Follow>>> source;
  List<String>? tags;

  FollowUpdater(this.source) {
    source.addListener(updateSource);
  }

  @override
  void dispose() {
    source.removeListener(updateSource);
    super.dispose();
  }

  Future<void> updateSource() async {
    List<String> update = (await source.value).tags;
    if (tags == null) {
      tags = update;
    } else {
      if (!UnorderedIterableEquality().equals(tags, update)) {
        tags = update;
        refresh();
      }
    }
  }

  @override
  Future<List<Follow>> read() => source.value;

  @override
  Future<void> write(List<Follow>? data) async {
    if (data != null) {
      source.value = Future.value(data);
    }
  }

  Future<void> sort(List<Follow> data) async {
    await data.sortByNew();
    await write(data);
  }

  @override
  Future<List<Follow>?> run(
    List<Follow> data,
    StepCallback step,
    bool force,
  ) async {
    await sort(data);

    DateTime now = DateTime.now();

    for (Follow follow in data) {
      if (follow.type != FollowType.bookmark) {
        DateTime? updated = await follow.updated;
        if (force || updated == null || now.difference(updated) > stale) {
          if (!await follow.refresh()) {
            fail();
            return null;
          }
          write(data);
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
      if (!step()) {
        return null;
      }
    }

    await sort(data);
    return data;
  }
}