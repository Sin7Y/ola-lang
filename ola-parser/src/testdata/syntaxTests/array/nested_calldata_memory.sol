pragma abicoder               v2;

contract Test {
    struct shouldBug {
        bytes[2] deadly;
    }
    fn killer(bytes[2] calldata weapon) pure external {
      shouldBug(weapon);
    }
}

// ----
