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
// EVMVersion: >=byzantium
// compileViaYul: also
// ----
// f() -> 0x1 # This should work, next should throw #
// gas legacy: 103716
// fview() -> FAILURE
// gas irOptimized: 98438619
// gas legacy: 98438801
// gas legacyOptimized: 98438594
// fpure() -> FAILURE
// gas irOptimized: 98438619
// gas legacy: 98438801
// gas legacyOptimized: 98438595
