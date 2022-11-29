contract A {
    struct S {
        address a;
    }
    S s;
    fn f() public {
        s.a = address(this);
    }
}
contract B {
    struct S {
        address payable a;
    }
    S s;
    fn f() public {
        s.a = payable(this);
    }
    receive() external payable {
    }
}
// ----
