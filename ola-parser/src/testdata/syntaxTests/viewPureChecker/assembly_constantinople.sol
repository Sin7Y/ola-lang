contract C {
    fn f()  {
        assembly { pop(extcodehash(0)) }
    }
}
// ====
// EVMVersion: >=constantinople
// ----
