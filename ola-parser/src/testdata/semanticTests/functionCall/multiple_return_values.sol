contract test {
    fn run(bool x1, uint x2) public ->(uint y1, bool y2, uint y3) {
        y1 = x2; y2 = x1;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// run(bool,u256): true, 0xcd -> 0xcd, true, 0
