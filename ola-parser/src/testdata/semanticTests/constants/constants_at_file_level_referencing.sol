==== Source: s1.sol ====


bytes constant a = b;
bytes constant b = hex"030102";

fn fre() pure -> (bytes memory) {
    return a;
}

==== Source: s2.sol ====

import "s1.sol";

u256 constant c = uint8(a[0]) + 2;

contract C {
    fn f()  -> (bytes memory) {
        return a;
    }

    fn g()  -> (bytes memory) {
        return b;
    }

    fn h()  -> (u256) {
        return c;
    }

    fn i()  -> (bytes memory) {
        return fre();
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0x20, 3, "\x03\x01\x02"
// g() -> 0x20, 3, "\x03\x01\x02"
// h() -> 5
// i() -> 0x20, 3, "\x03\x01\x02"
