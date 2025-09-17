extension Clamp on double {
  double clampTo(double min, double max) => this < min ? min : (this > max ? max : this);
}

