contract C {
    fn f()  {
        abi.encode;
        abi.encodePacked;
        abi.encodeWithSelector;
        abi.encodeWithSignature;
        abi.decode;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() ->
