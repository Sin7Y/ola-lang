type MyAddress is address;
contract C {
    fn f()   {
        MyAddress.wrap;
        MyAddress.unwrap;
    }
}
// ====
// compileViaYul: also
// ----
// f() ->
