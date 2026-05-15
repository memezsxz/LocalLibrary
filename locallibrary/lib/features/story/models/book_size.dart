enum BookSize { s, m, l }

extension BookSizeExt on BookSize {
  double maxExtent() => switch (this) {
    BookSize.s => 80.0,
    BookSize.m => 120.0,
    BookSize.l => 180.0,
  };
}
