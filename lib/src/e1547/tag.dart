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

import 'dart:collection' show IterableMixin;

import 'package:logging/logging.dart' show Logger;

class Tag {
  final String name;
  final String value;

  Tag(this.name, [this.value]);

  factory Tag.parse(String tag) {
    List<String> components = tag.trim().split(':');
    assert(components.length == 1 || components.length == 2);

    String name = components[0];
    String value = components.length == 2 ? components[1] : null;
    return new Tag(name, value);
  }

  @override
  String toString() => value == null ? name : '$name:$value';

  @override
  bool operator ==(Tag other) =>
      this.name == other.name && this.value == other.value;

  @override
  int get hashCode => this.toString().hashCode;
}

class Tagset extends Object with IterableMixin<Tag> {
  final Logger _log = new Logger('Tagset');

  final Map<String, Tag> _tags;

  // Get the URL for this search/tagset.
  Uri url(String host) => new Uri(
        scheme: 'https',
        host: host,
        path: '/post',
        queryParameters: {'tags': this.toString()},
      );

  Tagset(Set<Tag> tags)
      : _tags = new Map.fromIterable(
          tags,
          key: (t) => t.name,
          value: (t) => t,
        );

  Tagset.parse(String tagString) : _tags = new Map() {
    for (String ts in tagString.trim().split(new RegExp(r'\s+'))) {
      Tag t = new Tag.parse(ts);
      _log.fine('parsed tag: "$t"');
      _tags[t.name] = t;
    }

    _log.fine('tagset tags: $_tags');
  }

  bool contains(String tagName) {
    return _tags.containsKey(tagName);
  }

  operator []=(String name, String value) => _tags[name] = new Tag(name, value);

  void remove(String name) {
    _tags.remove(name);
  }

  @override
  Iterator<Tag> get iterator => _tags.values.iterator;

  @override
  String toString() {
    return _tags.values.join(' ');
  }
}