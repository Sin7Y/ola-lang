contract C {
    fn f()  {
        assembly { pop(basefee()) }
    }
    fn g()  -> (u256) {
        return block.basefee;
    }
}
// ====
// EVMVersion: >=london
// ----
// TypeError 2527: (67-76): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (147-160): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
