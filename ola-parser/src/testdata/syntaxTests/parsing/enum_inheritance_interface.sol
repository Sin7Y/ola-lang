interface I {
    enum Direction { Left, Right }
}

contract D is I {
    fn f() public pure returns (Direction) {
      return Direction.Left;
    }
}
// ----
