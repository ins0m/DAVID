part of visualizer;

class ColorTools {

  static List<int> hsvToRgb(num hue, num saturation, num value) {
    double h = hue.toDouble();
    double s = saturation.toDouble();
    double v = value.toDouble();
    double r, g, b;

    int i = (h * 6).toInt();
    double f = h * 6 - i;
    double p = v * (1 - s);
    double q = v * (1 - f * s);
    double t = v * (1 - (1 - f) * s);

    switch(i % 6) {
      case 0:
        r = v; g = t; b = p;
        break;
      case 1:
        r = q; g = v; b = p;
        break;
      case 2:
        r = p; g = v; b = t;
        break;
      case 3:
        r = p; g = q; b = v;
        break;
      case 4:
        r = t; g = p; b = v;
        break;
      case 5:
        r = v; g = p; b = q;
        break;
    }

    return [(r * 255 + 0.5).toInt(), (g * 255 + 0.5).toInt(), (b * 255 + 0.5).toInt()];
  }

  static String rgbToHex(int r, int g, int b) {
    return '#${((1 << 24) + (r << 16) + (g << 8) + b).toRadixString(16).substring(1, 7)}';
  }
}
