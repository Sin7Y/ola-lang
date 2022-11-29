contract C {
    uint[] s;
    fn f() internal returns (uint[] storage a)
    {
        revert();
        a[0] = 0;
        a = s;
    }
}
// ----
// Warning 5740: (112-135): Unreachable code.
