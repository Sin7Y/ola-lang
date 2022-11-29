contract Test {
    bytes6 name;

    constructor() {
        fn (bytes6 _name) internal setter = setName;
        setter("abcdef");

        applyShift(leftByteShift, 3);
    }

    fn getName()  -> (bytes6 ret) {
        return name;
    }

    fn setName(bytes6 _name) private {
        name = _name;
    }

    fn leftByteShift(bytes6 _value, u256 _shift)  -> (bytes6) {
        return _value << _shift * 8;
    }

    fn applyShift(fn (bytes6 _value, u256 _shift) internal -> (bytes6) _shiftOperator, u256 _bytes) internal {
        name = _shiftOperator(name, _bytes);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// getName() -> "def\x00\x00\x00"
