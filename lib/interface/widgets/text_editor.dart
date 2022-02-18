import 'dart:async';

import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class TextEditor extends StatefulWidget {
  final String title;
  final String? content;
  final bool dtext;
  final FutureOr<bool> Function(BuildContext context, String text)? onSubmit;

  const TextEditor({
    required this.title,
    required this.onSubmit,
    this.content,
    this.dtext = true,
  });

  @override
  State<StatefulWidget> createState() {
    return _TextEditorState();
  }
}

class _TextEditorState extends State<TextEditor>
    with TickerProviderStateMixin, ListenerCallbackMixin {
  bool showBar = true;
  bool isLoading = false;
  late TextEditingController textController =
      TextEditingController(text: widget.content);
  late TabController tabController;

  void onTabChange() {
    if (tabController.index == 0) {
      setState(() {
        showBar = true;
      });
    } else {
      FocusScope.of(context).unfocus();
      setState(() {
        showBar = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      vsync: this,
      length: 2,
    );
    tabController.addListener(onTabChange);
  }

  @override
  void dispose() {
    tabController.removeListener(onTabChange);
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget scrollView(Widget child) {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: child,
                  )
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget editor() {
      return scrollView(
        TextField(
          controller: textController,
          keyboardType: TextInputType.multiline,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'type here...',
          ),
          maxLines: null,
          enabled: !isLoading,
        ),
      );
    }

    Widget preview() {
      return scrollView(
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: AnimatedBuilder(
              animation: textController,
              builder: (context, child) {
                if (textController.text.trim().isNotEmpty) {
                  return DText(textController.text);
                } else {
                  return Text(
                    'your text here',
                    style: TextStyle(
                      color: dimTextColor(context),
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
    }

    Widget fab() {
      return Builder(
        builder: (context) => FloatingActionButton(
          heroTag: 'float',
          backgroundColor: Theme.of(context).cardColor,
          child: Icon(Icons.check, color: Theme.of(context).iconTheme.color),
          onPressed: isLoading
              ? null
              : () async {
                  String text = textController.text.trim();
                  setState(() {
                    isLoading = true;
                  });
                  if ((await widget.onSubmit?.call(context, text)) ?? true) {
                    Navigator.of(context).maybePop();
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
        ),
      );
    }

    Widget loadingBar() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedCircularProgressIndicator(size: 24),
              ],
            ),
          ],
        ),
      );
    }

    Map<Widget, Widget> tabs = {
      Tab(text: 'Write'): editor(),
      Tab(text: 'Preview'): preview(),
    };

    return Scaffold(
      floatingActionButton: fab(),
      bottomSheet: isLoading
          ? loadingBar()
          : (widget.dtext && showBar)
              ? DTextEditorBar(controller: textController)
              : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          DefaultSliverAppBar(
            floating: true,
            leading: CloseButton(),
            title: Text(widget.title),
            bottom: widget.dtext
                ? TabBar(
                    controller: tabController,
                    tabs: tabs.keys.toList(),
                    labelColor: Theme.of(context).iconTheme.color,
                    indicatorColor: Theme.of(context).iconTheme.color,
                  )
                : null,
          ),
        ],
        body: Padding(
          padding: defaultActionListPadding,
          child: widget.dtext
              ? TabBarView(
                  controller: tabController,
                  children: tabs.values.toList(),
                )
              : editor(),
        ),
      ),
    );
  }
}

class DTextEditorBar extends StatefulWidget {
  final TextEditingController controller;

  const DTextEditorBar({required this.controller});

  @override
  _DTextEditorBarState createState() => _DTextEditorBarState();
}

class _DTextEditorBarState extends State<DTextEditorBar> {
  bool showBlocks = false;

  @override
  Widget build(BuildContext context) {
    void enclose(String blockTag, {String? endTag}) {
      int base = widget.controller.selection.baseOffset;
      int extent = widget.controller.selection.extentOffset;

      int start;
      int end;
      if (base <= extent) {
        start = base;
        end = extent;
      } else {
        start = extent;
        end = base;
      }

      String before = widget.controller.text.substring(0, start);
      String block = widget.controller.text.substring(start, end);
      String after = widget.controller.text.substring(end);

      String blockStart = '[$blockTag]$block';
      String blockEnd = '[/${endTag ?? blockTag}]';
      int cursorOffset = before.length + blockStart.length;

      block = blockStart + blockEnd;
      widget.controller.text = '$before$block$after';

      widget.controller.selection = TextSelection(
        baseOffset: cursorOffset,
        extentOffset: cursorOffset,
      );
    }

    Widget blockButtons() {
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.subject),
            onPressed: () => enclose('section,expanded=', endTag: 'section'),
            tooltip: 'Section',
          ),
          IconButton(
            icon: Icon(Icons.format_quote),
            onPressed: () => enclose('quote'),
            tooltip: 'Quote',
          ),
          IconButton(
            icon: Icon(Icons.code),
            onPressed: () => enclose('code'),
            tooltip: 'Code',
          ),
          IconButton(
            icon: Icon(Icons.warning),
            onPressed: () => enclose('spoiler'),
            tooltip: 'Spoiler',
          ),
        ],
      );
    }

    Widget textButtons() {
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.format_bold),
            onPressed: () => enclose('b'),
            tooltip: 'Bold',
          ),
          IconButton(
            icon: Icon(Icons.format_italic),
            onPressed: () => enclose('i'),
            tooltip: 'Italic',
          ),
          IconButton(
            icon: Icon(Icons.format_underlined),
            onPressed: () => enclose('u'),
            tooltip: 'Underlined',
          ),
          IconButton(
            icon: Icon(Icons.format_strikethrough),
            onPressed: () => enclose('s'),
            tooltip: 'Strikethrough',
          ),
        ],
      );
    }

    Widget switcher() {
      return IntrinsicHeight(
        child: Row(
          children: [
            VerticalDivider(),
            ExpandIcon(
              isExpanded: showBlocks,
              onPressed: (value) => setState(() {
                showBlocks = !value;
              }),
            )
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int rowSize = (constraints.maxWidth / 40).round();
        bool showAll = rowSize > 10;
        return Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CrossFade(
                      showChild: showAll || showBlocks, child: blockButtons()),
                  CrossFade(
                      showChild: showAll || !showBlocks, child: textButtons()),
                  CrossFade(
                    showChild: !showAll,
                    child: switcher(),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
