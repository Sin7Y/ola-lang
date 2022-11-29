contract Foo {
    fn getX()  -> (u256 r) {
        return x;
    }

    u256 constant x = 56;
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// getX() -> 56
