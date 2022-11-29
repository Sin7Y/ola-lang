contract collatz {
    fn run(uint x) public ->(uint y) {
        while ((y = x) > 1) {
            if (x % 2 == 0) x = evenStep(x);
            else x = oddStep(x);
        }
    }
    fn evenStep(uint x) public ->(uint y) {
        return x / 2;
    }
    fn oddStep(uint x) public ->(uint y) {
        return 3 * x + 1;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// run(u256): 0 -> 0
// run(u256): 1 -> 1
// run(u256): 2 -> 1
// run(u256): 8 -> 1
// run(u256): 127 -> 1
