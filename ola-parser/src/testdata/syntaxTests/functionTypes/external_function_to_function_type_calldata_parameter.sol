// This is a test that checks that the type of the `bytes` parameter is
// correctly changed from its own type `bytes calldata` to `bytes memory`
// when converting to a fn type.
contract C {
    fn f(fn(bytes memory) pure external /*g*/) pure public { }
    fn callback(bytes calldata) pure external {}
    fn g() view public {
        f(this.callback);
    }
}
// ----
