pragma abicoder v1;
type MyUInt8 is uint8;

// Note that this wraps from a u256
fn wrap(u256 x) pure -> (MyUInt8 y) { assembly { y := x } }
fn unwrap(MyUInt8 x) pure -> (uint8 y) { assembly { y := x } }

contract C {
    uint8 a;
    MyUInt8 b;
    uint8 c;
    fn ret() external ->(MyUInt8) {
        return wrap(0x1ff);
    }
    fn f(MyUInt8 x) external ->(MyUInt8) {
        return x;
    }
    fn mem() external -> (MyUInt8[] memory) {
        MyUInt8[] memory x = new MyUInt8[](2);
        x[0] = wrap(0x1ff);
        x[1] = wrap(0xff);
        require(unwrap(x[0]) == unwrap(x[1]));
        assembly {
            mstore(add(x, 0x20), 0x1ff)
        }
        require(unwrap(x[0]) == unwrap(x[1]));
        return x;
    }
    fn stor() external -> (uint8, MyUInt8, uint8) {
        a = 1;
        c = 2;
        b = wrap(0x1ff);
        return (a, b, c);
    }
}

// ====
// compileViaYul: false
// ----
// ret() -> 0xff
// f(uint8): 0x1ff -> 0xff
// f(uint8): 0xff -> 0xff
// mem() -> 0x20, 2, 0x01ff, 0xff
// stor() -> 1, 0xff, 2
