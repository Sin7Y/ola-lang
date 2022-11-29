contract C {
    fn f()   {
        fn () external nonpayFun;
        nonpayFun();
    }
    fn g()   {
        fn () external view viewFun;
        viewFun();
    }
    fn h() view  {
        fn () external nonpayFun;
        nonpayFun();
    }
}
// ----
// TypeError 8961: (92-103): fn cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 2527: (193-202): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (289-300): fn cannot be declared as view because this expression (potentially) modifies the state.
