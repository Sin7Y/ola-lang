contract C {
    event Test(fn() external indexed);
    fn f()  {
        emit Test(this.f);
    }
}
// ====
// compileViaYul: also
// ----
// f() ->
// ~ emit Test(fn): #0x0fdd67305928fcac8d213d1e47bfa6165cd0b87b26121ff00000000000000000
