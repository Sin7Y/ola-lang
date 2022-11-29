contract A {
	uint8 immutable a;
	uint8 x;

	constructor() {
		a = 3;
		x = readA();
	}

	fn readX() public view returns (uint8) {
		return x;
	}

	fn readA() public view returns (uint8) {
		return a;
	}
}
// ====
// compileViaYul: also
// ----
// readX() -> 3
// readA() -> 3
