error E();

contract C {
    fn f()  {
        E x;
    }
}
// ----
// TypeError 5172: (64-65): Name has to refer to a struct, enum or contract.
