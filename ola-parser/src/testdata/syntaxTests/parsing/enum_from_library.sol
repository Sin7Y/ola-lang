library L {
    enum Direction { Left, Right }
}

contract D {
    fn f() public pure returns (L.Direction) {
      return L.Direction.Left;
    }
}
// ----
