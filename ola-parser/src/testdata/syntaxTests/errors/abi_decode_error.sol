error E(u256);
contract C {
    fn f()  -> (bytes memory) {
        return abi.decode(msg.data, (E));
    }
}
// ----
// TypeError 1039: (119-120): Argument has to be a type name.
// TypeError 5132: (90-122): Different number of arguments in return statement than in -> declaration.
