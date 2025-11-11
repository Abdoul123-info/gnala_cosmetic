String optimizeCloudinaryUrl(String url) {
  if (url.isEmpty) return url;
  // Only touch Cloudinary delivery URLs
  if (!url.contains('res.cloudinary.com')) return url;

  // If URL already contains f_auto or q_auto, leave it
  if (url.contains('f_auto') || url.contains('q_auto')) return url;

  // Insert default transformation segment after 'upload/'
  final needle = '/upload/';
  final idx = url.indexOf(needle);
  if (idx == -1) return url;

  // Build new URL with transformations appended right after 'upload/'
  final before = url.substring(0, idx + needle.length);
  final after = url.substring(idx + needle.length);
  return '${before}f_auto,q_auto/${after}';
}

// Same as above but adds a safe max width using c_limit to avoid upscaling
String optimizeCloudinaryUrlWithWidth(String url, {int width = 800}) {
  if (url.isEmpty) return url;
  if (!url.contains('res.cloudinary.com')) return url;

  final needle = '/upload/';
  final idx = url.indexOf(needle);
  if (idx == -1) return url;

  // If a width or transformation already present, we still prepend ours unless f_auto/q_auto exist
  final before = url.substring(0, idx + needle.length);
  final after = url.substring(idx + needle.length);

  final hasFAuto = url.contains('f_auto');
  final hasQAuto = url.contains('q_auto');

  final f = hasFAuto ? '' : 'f_auto,';
  final q = hasQAuto ? '' : 'q_auto,';

  // c_limit prevents upscaling; dpr_auto serves higher density on retina screens
  return '${before}${f}${q}c_limit,w_${width},dpr_auto/${after}';
}


