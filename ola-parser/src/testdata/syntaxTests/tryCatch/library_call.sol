library L {
    struct S { u256 x; }
    fn integer(u256 t, bool b)  -> (u256) {
        if (b) {
            return t;
        } else {
            revert("failure");
        }
    }
    fn stru(S storage t, bool b)  -> (u256) {
        if (b) {
            return t.x;
        } else {
            revert("failure");
        }
    }
}
contract C {
    using L for L.S;
    L.S t;
    fn f(bool b)  -> (u256, string memory) {
        u256 x = 8;
        try L.integer(x, b) -> (u256 _x) {
            return (_x, "");
        } catch Error(string memory message) {
            return (18, message);
        }
    }
    fn g(bool b)  -> (u256, string memory) {
        t.x = 9;
        try t.stru(b) -> (u256 x) {
            return (x, "");
        } catch Error(string memory message) {
            return (19, message);
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
