import 'package:flutter/material.dart';

import 'models.dart';

export 'search/actions.dart';

class UpdateCurrentTabAction {
  final AppTab newTab;

  UpdateCurrentTabAction(this.newTab);

  @override
  String toString() {
    return 'UpdateTabAction{newTab: $newTab}';
  }
}

class UpdateInitialTabAction {
  final AppTab initialTab;

  UpdateInitialTabAction(this.initialTab);

  @override
  String toString() {
    return 'UpdateTabAction{newTab: $initialTab}';
  }
}

class UploadImage {
  final Image uploadImage;

  UploadImage(this.uploadImage);

  @override
  String toString() {
    return 'UploadImage{}';
  }
}
