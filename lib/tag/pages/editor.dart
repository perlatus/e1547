import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';

class TagEditor extends StatefulWidget {
  final Post post;
  final String category;
  final Future<bool> Function(String text) onSubmit;
  final Function(Future<bool> Function() submit) builder;

  TagEditor({
    @required this.post,
    @required this.category,
    this.onSubmit,
    this.builder,
  });

  @override
  _TagEditorState createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  ValueNotifier loading = ValueNotifier(false);
  TextEditingController controller = TextEditingController();

  Future<bool> submit(value) async {
    loading.value = true;
    bool success = await widget.onSubmit(value);
    loading.value = false;
    return success;
  }

  @override
  void initState() {
    super.initState();
    widget.builder?.call(() => submit(controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: loading,
                builder: (context, value, child) {
                  return CrossFade(
                    showChild: value,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Container(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: TagInput(
                  labelText: widget.category,
                  onSubmit: submit,
                  controller: controller,
                  category: categories[widget.category],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}