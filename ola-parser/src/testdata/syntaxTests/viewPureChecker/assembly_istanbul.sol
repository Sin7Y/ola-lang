contract C {
    fn f()  {
        assembly { pop(chainid()) }
    }
    fn g()  -> (u256) {
        return block.chainid;
    }
}
// ====
// EVMVersion: >=istanbul
// ----
