abstract contract A {
    fn f() virtual ;
}

interface I {
    fn f() external pure;
}

contract C {
    fn f()   {
    }
}

contract Test is C {
    fn c()  -> (string memory) {
        return type(C).name;
    }
    fn a()  -> (string memory) {
        return type(A).name;
    }
    fn i()  -> (string memory) {
        return type(I).name;
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// c() -> 0x20, 1, "C"
// a() -> 0x20, 1, "A"
// i() -> 0x20, 1, "I"
