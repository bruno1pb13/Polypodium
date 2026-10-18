import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';

/// Pages of the project site the app points people to. The site has a
/// Portuguese and an English edition; any other locale gets the English one.
abstract final class ExternalLinks {
  static const _site = 'https://polypodium.com.br';

  static bool _isPt(String localeName) => localeName.startsWith('pt');

  /// How to run a sync server and connect the app to it.
  static Uri serverDocs(String localeName) => Uri.parse(_isPt(localeName)
      ? '$_site/self-host.html'
      : '$_site/self-host.en.html');

  /// The download section, listing every platform. Android builds link here
  /// rather than to GitHub: a Play build must not offer other installers of
  /// itself, and the site only lists the desktop ones next to the store.
  static Uri downloads(String localeName) => Uri.parse(_isPt(localeName)
      ? '$_site/#download'
      : '$_site/index.en.html#download');

  static final playStore = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.zapperbrz.polypodium');
}

/// Opens [url] in the browser, telling the user when no app could open it.
Future<void> openExternalLink(BuildContext context, Uri url) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final message = context.l10n.linkOpenFailed(url.toString());
  var opened = false;
  try {
    opened = await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!opened) messenger?.showSnackBar(SnackBar(content: Text(message)));
}
