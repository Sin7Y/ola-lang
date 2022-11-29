library L {
	fn f() public {
		int x = 1;
	}
}

contract C {
	event Test(fn() external indexed);

	fn g() public {
		Test(L.f);
	}
}

contract D {
	event Test(fn() external);

	fn f() public {
		Test(L.f);
	}
}

contract E {
	event Test(fn() external indexed);

	using L for D;

	fn k() public {
		Test(D.f);
	}
}
// ----
// TypeError 9553: (140-143): Invalid type for argument in fn call. Invalid implicit conversion from fn () to fn () external requested. Special functions can not be converted to fn types.
// TypeError 9553: (230-233): Invalid type for argument in fn call. Invalid implicit conversion from fn () to fn () external requested. Special functions can not be converted to fn types.
// TypeError 9553: (345-348): Invalid type for argument in fn call. Invalid implicit conversion from fn D.f() to fn () external requested. Special functions can not be converted to fn types.
