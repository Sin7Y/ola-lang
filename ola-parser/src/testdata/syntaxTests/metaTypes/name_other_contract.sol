contract Test {
    fn f()  -> (string memory) {
        return type(C).name;
    }
    fn g()  -> (string memory) {
        return type(A).name;
    }
    fn h()  -> (string memory) {
        return type(I).name;
    }
}

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
// ----
