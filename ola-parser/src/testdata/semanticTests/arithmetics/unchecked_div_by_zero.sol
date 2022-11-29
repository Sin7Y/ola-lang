contract C {
    fn div(u256 a, u256 b) public -> (u256) {
        // Does not disable div by zero check
        unchecked {
            return a / b;
        }
    }

    fn mod(u256 a, u256 b) public -> (u256) {
        // Does not disable div by zero check
        unchecked {
            return a % b;
        }
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// div(u256,u256): 7, 2 -> 3
// div(u256,u256): 7, 0 -> FAILURE, hex"4e487b71", 0x12 # throws #
// mod(u256,u256): 7, 2 -> 1
// mod(u256,u256): 7, 0 -> FAILURE, hex"4e487b71", 0x12 # throws #
