error E(u256);
contract C {
    fn f()  -> (bytes memory) {
        return abi.encode(E);
    }
}
// ----
// TypeError 2056: (108-109): This type cannot be encoded.
