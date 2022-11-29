abstract contract A { modifier mod(u256 a) virtual;}
contract B is A { modifier mod(u256 a) override { _; } }

abstract contract C {
	modifier m virtual;
	fn f() m  {

	}
}
contract D is C {
	modifier m override {
		_;
	}
}
// ----
