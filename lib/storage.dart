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

import 'package:flutter/services.dart' show NetworkImage, ImageProvider;

import 'http.dart' show HttpCustom;

HttpCustom _http = new HttpCustom();

/// Retrieve an image, using cache if possible. If the image is loaded from
/// [location], then it will be saved to the cache.
ImageProvider getImage(Uri location) {
  // Uint8List imageBytes; // = _http.getUrl(location).then((r) => r.bodyBytes);
  return new NetworkImage(location.toString());
}
