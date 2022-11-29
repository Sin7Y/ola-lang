error E(u256);
contract C {
    fn f()  -> (bytes memory) {
        return abi.encode(E(2));
    }
}
// ----
// TypeError 2056: (108-112): This type cannot be encoded.
