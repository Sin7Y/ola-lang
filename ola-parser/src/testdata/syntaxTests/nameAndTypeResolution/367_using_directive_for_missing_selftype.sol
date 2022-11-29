library B {
    fn b() public {}
}

contract A {
    using B for bytes;

    fn a() public {
        bytes memory x;
        x.b();
    }
}
// ----
// TypeError 9582: (137-140): Member "b" not found or not visible after argument-dependent lookup in bytes memory.
