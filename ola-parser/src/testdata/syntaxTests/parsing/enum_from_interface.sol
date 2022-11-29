interface I {
    enum Direction { Left, Right }
}

contract D {
    fn f() public pure returns (I.Direction) {
      return I.Direction.Left;
    }
}
// ----
