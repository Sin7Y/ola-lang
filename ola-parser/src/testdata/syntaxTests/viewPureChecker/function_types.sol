contract C {
    fn f()   {
        fn () external nonpayFun;
        fn () external view viewFun;
        fn () external pure pureFun;

        nonpayFun;
        viewFun;
        pureFun;
        pureFun();
    }
    fn g() view  {
        fn () external view viewFun;

        viewFun();
    }
    fn h()  {
        fn () external nonpayFun;

        nonpayFun();
    }
}
// ----
