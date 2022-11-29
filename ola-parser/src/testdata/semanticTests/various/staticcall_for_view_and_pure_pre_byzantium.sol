contract C {
    u256 x;

    fn f()  -> (u256) {
        x = 3;
        return 1;
    }
}


interface CView {
    fn f() external view -> (u256);
}


interface CPure {
    fn f() external pure -> (u256);
}


contract D {
    fn f()  -> (u256) {
        return (new C()).f();
    }

    fn fview()  -> (u256) {
        return (CView(address(new C()))).f();
    }

    fn fpure()  -> (u256) {
        return (CPure(address(new C()))).f();
    }
}
// ====
// compileViaYul: also
// EVMVersion: <byzantium
// ----
// f() -> 0x1
// fview() -> 1
// fpure() -> 1
