contract C {
    fn f(u256 i)  -> (string memory) {
        string[4] memory x = ["This", "is", "an", "array"];
        return (x[i]);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256): 0 -> 0x20, 0x4, "This"
// f(u256): 1 -> 0x20, 0x2, "is"
// f(u256): 2 -> 0x20, 0x2, "an"
// f(u256): 3 -> 0x20, 0x5, "array"
