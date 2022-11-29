contract A {
    uint immutable public x = 1;
    uint public y;
    constructor() {
        y = this.x();
    }
}
contract C {
    fn f() public returns (bool) {
        try new A() { return false; }
        catch { return true; }
    }
}
// ====
// EVMVersion: >=tangerineWhistle
// compileViaYul: also
// ----
// f() -> true
