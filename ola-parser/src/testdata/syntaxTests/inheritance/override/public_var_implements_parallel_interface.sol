interface A {
    fn foo() external -> (u256);
    fn goo() external -> (u256);
}
interface B {
    fn foo() external -> (u256);
    fn goo() external -> (u256);
}
contract X is A, B {
	u256  override(A, B) foo;
    fn goo() external virtual override(A, B) -> (u256) {}
}
abstract contract T is A {
    fn foo() external virtual -> (u256);
    fn goo() external virtual -> (u256);
}
contract Y is X, T {
}
// ----
// TypeError 6480: (466-488): Derived contract must override fn "foo". Two or more base classes define fn with same name and parameter types. Since one of the bases defines a  state variable which cannot be overridden, you have to change the inheritance layout or the names of the functions.
// TypeError 6480: (466-488): Derived contract must override fn "goo". Two or more base classes define fn with same name and parameter types.
