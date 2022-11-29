contract A{
    fn f() public pure{

    }
}
contract B{
    A private a;
}
contract C{
    B b;
    fn f() public view{
        b.a.f();
    }
}

// ----
// TypeError 9582: (141-144): Member "a" not found or not visible after argument-dependent lookup in contract B.
