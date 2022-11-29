contract A {
    fn x()  {}
}

contract B is A {
    fn f()  {
        A.x();
    }
}
// ----
// TypeError 8961: (100-105): fn cannot be declared as view because this expression (potentially) modifies the state.
