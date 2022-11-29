interface I {
    enum Direction { Left, Right }
}

library L {
    fn f() public pure returns (I.Direction) {
      return I.Direction.Left;
    }
    fn g() internal pure returns (I.Direction) {
      return I.Direction.Left;
    }
}
// ----
