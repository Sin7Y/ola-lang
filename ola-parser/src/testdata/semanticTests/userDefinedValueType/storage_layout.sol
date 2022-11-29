type MyInt8 is int8;
type MyAddress is address;
type MyInt96 is int96;

contract C {
    MyInt8 a;
    MyInt8 b;
    MyInt8 c;
    MyAddress d;

    MyAddress e;

    MyAddress f;
    MyInt96 g;

    fn storage_a() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := a.slot
            offset := a.offset
        }
    }

    fn storage_b() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := b.slot
            offset := b.offset
        }
    }

    fn storage_c() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := d.slot
            offset := c.offset
        }
    }
    fn storage_d() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := d.slot
            offset := d.offset
        }
    }

    fn storage_e() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := e.slot
            offset := e.offset
        }
    }

    fn storage_f() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := f.slot
            offset := f.offset
        }
    }

    fn storage_g() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := g.slot
            offset := g.offset
        }
    }

}
// ====
// compileViaYul: also
// ----
// storage_a() -> 0, 0
// storage_b() -> 0, 1
// storage_c() -> 0, 2
// storage_d() -> 0, 3
// storage_e() -> 1, 0
// storage_f() -> 2, 0
// storage_g() -> 2, 0x14
