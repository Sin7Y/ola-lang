contract C {
    enum Direction { Left, Right }
}

contract D is C {
    fn f() public pure returns (Direction) {
      return Direction.Left;
    }
}
// ----
