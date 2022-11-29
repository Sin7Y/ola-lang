fn f(u256) -> (bytes memory) {}
fn f(u256[] memory x) -> (bytes memory) { return f(x[0]); }
fn g(uint8) {}
fn g(uint16) {}
fn t() {
    g(2);
}
// ----
// TypeError 4487: (176-177): No unique declaration found after argument-dependent lookup.
