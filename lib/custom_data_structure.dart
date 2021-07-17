class Chord {
  int root, rootSharp, rootTension, minorTension, majorTension, tension, tensionSharp, asdaTension, base, baseSharp;
  String minor, major, asda;

  Chord({
    this.root = -1,
    this.rootSharp = 0,
    this.rootTension = -1,
    this.minor = "",
    this.minorTension = -1,
    this.major = "",
    this.majorTension = -1,
    this.tensionSharp = 0,
    this.tension = -1,
    this.asda = "",
    this.asdaTension = -1,
    this.base = -1,
    this.baseSharp = 0
  });

  String toString() {
    return "";
  }
}