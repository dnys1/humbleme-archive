import '../../auth/models/mindset.dart';

class TopMindsetsData {
  final List<Mindset> topMindsets;

  TopMindsetsData(this.topMindsets);

  TopMindsetsData copyWith(Mindset mindset) {
    if (topMindsets.length < 5) {
      var newTopMindsets = topMindsets;
      newTopMindsets.add(mindset);
      return TopMindsetsData(newTopMindsets);
    }
    return this;
  }

  @override
  String toString() {
    return 'TopMindsets{topMindsets: $topMindsets}';
  }
}
