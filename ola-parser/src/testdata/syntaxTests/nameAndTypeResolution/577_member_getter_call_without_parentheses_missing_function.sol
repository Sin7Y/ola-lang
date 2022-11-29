contract A{

}
contract B{
    A public a;
}
contract C{
    B b;
    fn f() public view{
        b.a.f();
    }
}

// ----
// TypeError 6005: (104-109): Member "f" not found or not visible after argument-dependent lookup in fn () view external returns (contract A). Did you intend to call the fn?
