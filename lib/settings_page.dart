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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'persistence.dart' show db;

class SettingsPageScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Settings')),
      body: new SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  String _host;
  bool _hideSwf;
  String _username;

  Function _onTapSiteBackend(BuildContext ctx) {
    return () async {
      String newHost = await showDialog<String>(
        context: ctx,
        child: new _SiteBackendDialog(_host),
      );

      if (newHost != null) {
        db.host.value = new Future.value(newHost);
        setState(() {
          _host = newHost;
        });
      }
    };
  }

  @override
  void initState() {
    super.initState();
    db.host.value.then((a) async => _host = a);
    db.hideSwf.value.then((a) async => _hideSwf = a);
    db.username.value.then((a) async => _username = a);
  }

  void _onChangedHideSwf(bool newHideSwf) {
    db.hideSwf.value = new Future.value(newHideSwf);
    setState(() {
      _hideSwf = newHideSwf;
    });
  }

  Function _onTapSignOut(BuildContext ctx) {
    return () async {
      String username = await db.username.value;
      db.username.value = new Future.value(null);
      db.apiKey.value = new Future.value(null);

      Scaffold.of(ctx).showSnackBar(new SnackBar(
            duration: const Duration(seconds: 5),
            content: new Text('Forgot login details for $username'),
          ));

      setState(() {
        _username = null;
      });
    };
  }

  @override
  Widget build(BuildContext ctx) {
    return new Container(
      padding: const EdgeInsets.all(10.0),
      child: new ListView(
        children: [
          new ListTile(
            title: new Text('Site backend'),
            subtitle: _host != null ? new Text(_host) : null,
            onTap: _onTapSiteBackend(ctx),
          ),
          new CheckboxListTile(
            title: new Text('Hide Flash posts'),
            value: _hideSwf ?? false,
            onChanged: _onChangedHideSwf,
          ),
          new ListTile(
            title: new Text('Sign out'),
            subtitle: _username != null ? new Text(_username) : null,
            onTap: _onTapSignOut(ctx),
          ),
        ],
      ),
    );
  }
}

class _SiteBackendDialog extends StatefulWidget {
  const _SiteBackendDialog(this.host);

  final String host;

  @override
  _SiteBackendDialogState createState() => new _SiteBackendDialogState();
}

class _SiteBackendDialogState extends State<_SiteBackendDialog> {
  @override
  Widget build(BuildContext ctx) {
    return new SimpleDialog(
      title: new Text('Site backend'),
      children: [
        new RadioListTile<String>(
          value: 'e926.net',
          title: new Text('e926.net'),
          groupValue: widget.host,
          onChanged: Navigator.of(ctx).pop,
        ),
        new RadioListTile<String>(
          value: 'e621.net',
          title: new Text('e621.net'),
          groupValue: widget.host,
          onChanged: Navigator.of(ctx).pop,
        ),
      ],
    );
  }
}
