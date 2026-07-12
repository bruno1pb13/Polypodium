import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/enums.dart';

part 'plant_detail_view_provider.g.dart';

/// Which view of the plant detail screen is active (diary/charts/photos).
@riverpod
class PlantDetailViewNotifier extends _$PlantDetailViewNotifier {
  @override
  PlantDetailView build(String plantId) => PlantDetailView.diary;

  void setView(PlantDetailView view) => state = view;
}
