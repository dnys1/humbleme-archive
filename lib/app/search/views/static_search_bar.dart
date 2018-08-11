import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StaticSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function onCancel;
  final Function onClear;
  final Function(String) onUpdate;
  final Function(String) onSubmit;
  final String searchText;

  StaticSearchBar({
    @required this.controller,
    @required this.focusNode,
    @required this.searchText,
    this.onCancel,
    this.onClear,
    this.onSubmit,
    this.onUpdate,
  });

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final GlobalKey<FormFieldState<String>> _searchKey =
      GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 3.0),
      child: Form(
        key: _formKey,
        onChanged: () {
          onUpdate(controller.text);
        },
        child: TextFormField(
          key: _searchKey,
          controller: controller,
          focusNode: focusNode,
          onFieldSubmitted: onSubmit,
          style: TextStyle(fontSize: 18.0, color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Icon(Icons.search),
            ),
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
