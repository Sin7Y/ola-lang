library D { fn length(string memory self)  -> (u256) { return bytes(self).length; } }
contract C {
    using D for string;
    string x;
    fn f()  -> (u256) {
        x = "abc";
        return x.length();
    }
    fn g()  -> (u256) {
        string memory s = "abc";
        return s.length();
    }
}
// ====
// compileToEwasm: false
// compileViaYul: also
// ----
// library: D
// f() -> 3
// g() -> 3
