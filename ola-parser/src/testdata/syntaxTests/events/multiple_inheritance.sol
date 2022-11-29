contract A {
    event X(u256);
}

contract B is A {}

contract C is A {}

contract D is B, C {

}
// ----
