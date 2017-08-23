// e1547: A mobile app for browsing e926.net and friends.
// Copyright (C) 2017 perlatus <perlatus@e1547.email.vczf.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import 'dart:async' show Future;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

import 'pagination.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    if (rec.object == null) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    } else {
      print('${rec.level.name}: ${rec.time}: ${rec.message}: ${rec.object}');
    }
  });

  const numberLoaderMap = const {
    0: const ['0', '0', '0'],
    1: const ['1', '1', '1'],
    2: const ['2', '2', '2'],
    3: const ['3', '3', '3'],
    4: const ['4', '4'],
  };

  Future<List<String>> numberLoader(int page) async {
    if (page < 0 || page > 4) {
      return [];
    } else {
      return numberLoaderMap[page];
    }
  }

  test('Load in order', () async {
    Pagination<String> p = new Pagination<String>(3, numberLoader);
    List<String> elementsAns = [];
    for (int i = 0; i < 4; i++) {
      expect(await p.loadPage(i), equals(numberLoaderMap[i].length));
      expect(p.elements, equals(elementsAns..addAll(numberLoaderMap[i])));
    }
  });

  test('Load out of bounds', () async {
    Pagination<String> p = new Pagination<String>(3, numberLoader);
    expect(await p.loadPage(5), equals(0));
    expect(p.elements.isEmpty, isTrue);
    expect(await p.loadPage(-1), equals(0));
    expect(p.elements.isEmpty, isTrue);
  });

  test('Load sparse', () async {
    Pagination<String> p = new Pagination<String>(3, numberLoader);
    List<String> elementsAns = new List.filled(14, null);

    expect(await p.loadPage(4), equals(2));
    elementsAns.setRange(12, 14, numberLoaderMap[4]);

    expect(p.elements, equals(elementsAns));

    expect(await p.loadPage(2), equals(3));
    elementsAns.setRange(6, 9, numberLoaderMap[2]);

    expect(p.elements, equals(elementsAns));

    expect(await p.loadPage(0), equals(3));
    elementsAns.setRange(0, 3, numberLoaderMap[0]);

    expect(p.elements, equals(elementsAns));
  });
}
