contract D { constructor() payable {} }
contract C {
    fn foo() pure internal {
		new D{salt:"abc", value:3};
		new D{salt:"abc"};
		new D{value:5+5};
		new D{salt:"aabbcc"};
    }
}
// ====
// EVMVersion: >=constantinople
// ----
