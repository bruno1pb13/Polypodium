import '../../entries/domain/entry_model.dart';

/// A photo of one of the plant's entries, dated by that entry.
typedef PlantPhoto = ({EntryPhoto photo, EntryModel entry});

/// Every photo of [entries], oldest entry first and in entry order within
/// one entry.
List<PlantPhoto> plantPhotosOf(List<EntryModel> entries) {
  final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
  return [
    for (final entry in sorted)
      for (final photo in entry.photos) (photo: photo, entry: entry),
  ];
}

/// Id of the photo used as cover among [photos]: [picked] while it is one of
/// them, else the latest entry's first photo (as EntriesDao resolves it).
String? coverPhotoIdOf(List<PlantPhoto> photos, String? picked) {
  if (picked != null && photos.any((p) => p.photo.id == picked)) {
    return picked;
  }
  for (final p in photos.reversed) {
    if (p.photo.id == p.entry.id) return p.photo.id;
  }
  return null;
}
