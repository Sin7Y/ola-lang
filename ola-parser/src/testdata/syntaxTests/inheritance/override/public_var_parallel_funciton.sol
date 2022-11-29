interface A {
    fn foo() external -> (u256);
}
contract B {
    u256  foo;
}
contract X is A, B {
}
// ----
// TypeError 6480: (96-118): Derived contract must override fn "foo". Two or more base classes define fn with same name and parameter types. Since one of the bases defines a  state variable which cannot be overridden, you have to change the inheritance layout or the names of the functions.
