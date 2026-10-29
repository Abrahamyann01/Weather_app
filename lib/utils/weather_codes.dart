import 'package:flutter/material.dart';

String weatherDescription(int code) {
  if (code == 0) return 'Արևոտ';
  if (code == 1) return 'Հիմնականում արևոտ';
  if (code == 2) return 'Մասամբ ամպամած';
  if (code == 3) return 'Ամպամած';
  if ([45, 48].contains(code)) return 'Մառախուղ';
  if ([51, 53, 55, 56, 57].contains(code)) return 'Մանր անձրև';
  if ([61, 63, 65, 66, 67].contains(code)) return 'Անձրև';
  if ([71, 73, 75, 77].contains(code)) return 'Ձյուն';
  if ([80, 81, 82].contains(code)) return 'Անձրևային տեղումներ';
  if ([85, 86].contains(code)) return 'Ձյունատեղում';
  if ([95, 96, 99].contains(code)) return 'Ամպրոպ';
  return 'Փոփոխական եղանակ';
}

IconData weatherIcon(int code) {
  if (code == 0 || code == 1) {
    return Icons.wb_sunny_rounded;
  }
  if (code == 2) return Icons.wb_cloudy_rounded;

  if ([3, 45, 48].contains(code)) {
    return Icons.cloud_rounded;
  }

  if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
    return Icons.umbrella_rounded;
  }

  if ([71, 73, 75, 77, 85, 86].contains(code)) {
    return Icons.ac_unit_rounded;
  }

  if ([95, 96, 99].contains(code)) {
    return Icons.thunderstorm_rounded;
  }

  return Icons.cloud_rounded;
}

bool isRainy(int code) {
  return [
    51,
    53,
    55,
    56,
    57,
    61,
    63,
    65,
    66,
    67,
    80,
    81,
    82,
    95,
    96,
    99,
  ].contains(code);
}
