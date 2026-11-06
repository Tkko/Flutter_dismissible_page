import 'package:flutter/painting.dart';

/// Text styles of the demo app, all set in the bundled Poppins family.
///
/// Names follow the size, `Strong` is semi-bold, `Bold` is bold. Add colors or
/// other tweaks with `copyWith`.
abstract final class DemoText {
  static const String family = 'Poppins';

  /// The family at the inherited size and weight.
  static const TextStyle plain = TextStyle(fontFamily: family);
  static const TextStyle plainSemiBold =
      TextStyle(fontFamily: family, fontWeight: FontWeight.w600);
  static const TextStyle plainBold =
      TextStyle(fontFamily: family, fontWeight: FontWeight.w700);

  /// 36 / ExtraBold
  static const TextStyle display = TextStyle(
    fontFamily: family,
    fontSize: 36,
    fontWeight: FontWeight.w800,
  );

  /// 30 / Bold
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: family,
    fontSize: 30,
    fontWeight: FontWeight.w700,
  );

  /// 28 / Bold
  static const TextStyle headline = TextStyle(
    fontFamily: family,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  /// 26 / Bold
  static const TextStyle titleXLarge = TextStyle(
    fontFamily: family,
    fontSize: 26,
    fontWeight: FontWeight.w700,
  );

  /// 24 / Bold
  static const TextStyle titleLarge = TextStyle(
    fontFamily: family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  /// 24 / Medium
  static const TextStyle titleLargeMedium = TextStyle(
    fontFamily: family,
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  /// 22 / Bold
  static const TextStyle title = TextStyle(
    fontFamily: family,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  /// 22 / SemiBold
  static const TextStyle titleSemiBold = TextStyle(
    fontFamily: family,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  /// 20 / Bold
  static const TextStyle heading = TextStyle(
    fontFamily: family,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  /// 18 / Bold
  static const TextStyle subheadingBold = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  /// 18 / SemiBold
  static const TextStyle subheading = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// 18 / Medium
  static const TextStyle subheadingMedium = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  /// 16 / SemiBold
  static const TextStyle lead = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// 16 / Medium
  static const TextStyle leadMedium = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// 16 / Regular
  static const TextStyle leadRegular = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// 15.5 / Regular
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: family,
    fontSize: 15.5,
    fontWeight: FontWeight.w400,
  );

  /// 15 / Regular
  static const TextStyle body = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  /// 15 / SemiBold
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// 14 / Regular
  static const TextStyle bodySmall = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// 14 / SemiBold
  static const TextStyle bodySmallStrong = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// 13 / Regular
  static const TextStyle caption = TextStyle(
    fontFamily: family,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  /// 13 / Medium
  static const TextStyle captionMedium = TextStyle(
    fontFamily: family,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  /// 13 / SemiBold
  static const TextStyle captionStrong = TextStyle(
    fontFamily: family,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// 12.5 / Regular
  static const TextStyle labelLarge = TextStyle(
    fontFamily: family,
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
  );

  /// 12 / Regular
  static const TextStyle label = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// 12 / SemiBold
  static const TextStyle labelStrong = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  /// 11 / Regular
  static const TextStyle micro = TextStyle(
    fontFamily: family,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  /// 11 / SemiBold
  static const TextStyle microStrong = TextStyle(
    fontFamily: family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  /// 10.5 / Medium
  static const TextStyle microMedium = TextStyle(
    fontFamily: family,
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
  );
}
