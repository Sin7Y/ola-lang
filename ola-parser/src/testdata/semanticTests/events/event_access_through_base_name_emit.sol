contract A {
    event x();
}
contract B is A {
    fn f()  -> (u256) {
        emit A.x();
        return 1;
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 1
// ~ emit x()
