pragma abicoder v1;

type MyUInt8 is uint8;
type MyInt8 is int8;
type MyUInt16 is uint16;

contract C {
    fn f(u256 a) external ->(MyUInt8) {
        return MyUInt8.wrap(uint8(a));
    }
    fn g(u256 a) external ->(MyInt8) {
        return MyInt8.wrap(int8(int(a)));
    }
    fn h(MyUInt8 a) external -> (MyInt8) {
        return MyInt8.wrap(int8(MyUInt8.unwrap(a)));
    }
    fn i(MyUInt8 a) external ->(MyUInt16) {
        return MyUInt16.wrap(MyUInt8.unwrap(a));
    }
    fn j(MyUInt8 a) external -> (u256) {
        return MyUInt8.unwrap(a);
    }
    fn k(MyUInt8 a) external -> (MyUInt16) {
        return MyUInt16.wrap(MyUInt8.unwrap(a));
    }
    fn m(MyUInt16 a) external -> (MyUInt8) {
        return MyUInt8.wrap(uint8(MyUInt16.unwrap(a)));
    }
}

// ====
// compileViaYul: false
// ----
// f(u256): 1 -> 1
// f(u256): 2 -> 2
// f(u256): 257 -> 1
// g(u256): 1 -> 1
// g(u256): 2 -> 2
// g(u256): 255 -> -1
// g(u256): 257 -> 1
// h(uint8): 1 -> 1
// h(uint8): 2 -> 2
// h(uint8): 255 -> -1
// h(uint8): 257 -> 1
// i(uint8): 250 -> 250
// j(uint8): 1 -> 1
// j(uint8): 2 -> 2
// j(uint8): 255 -> 0xff
// j(uint8): 257 -> 1
// k(uint8): 1 -> 1
// k(uint8): 2 -> 2
// k(uint8): 255 -> 0xff
// k(uint8): 257 -> 1
// m(uint16): 1 -> 1
// m(uint16): 2 -> 2
// m(uint16): 255 -> 0xff
// m(uint16): 257 -> 1
