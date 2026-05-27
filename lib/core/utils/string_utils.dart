extension StringNormalization on String {
  /// Normalizes a string by converting it to lowercase and removing accents/diacritics.
  String normalize() {
    var str = toLowerCase();
    const withDia = 'àáâãäåòóôõöøèéêëìíîïùúûüÿñç·/_,:;';
    const diagFree = 'aaaaaaooooooeeeeiiiiuuuuync------';

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], diagFree[i]);
    }

    return str;
  }
}
