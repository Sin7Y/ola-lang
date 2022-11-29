type MyInt64 is int64;
struct HalfSlot {
    MyInt64 a;
    MyInt64 b;
}

struct RegularHalfSlot {
    int64 a;
    int64 b;
}

type MyAddress is address;
type MyInt96 is int96;
struct FullSlot {
    MyInt96 a;
    MyAddress b;
}
struct RegularFullSlot {
    int96 a;
    address b;
}

contract C {
    HalfSlot  a;
    RegularHalfSlot  ra;

    HalfSlot  b;
    RegularHalfSlot  rb;

    HalfSlot  c;
    RegularHalfSlot  rc;

    FullSlot  d;
    RegularFullSlot  rd;

    fn storage_a() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := a.slot
            offset := a.offset
        }
    }

    fn storage_ra() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := ra.slot
            offset := ra.offset
        }
    }

    fn storage_b() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := b.slot
            offset := b.offset
        }
    }

    fn storage_rb() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := rb.slot
            offset := rb.offset
        }
    }

   fn storage_c() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := c.slot
            offset := c.offset
        }
    }

   fn storage_rc() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := rc.slot
            offset := rc.offset
        }
    }

   fn storage_d() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := d.slot
            offset := d.offset
        }
    }

   fn storage_rd() pure external ->(u256 slot, u256 offset) {
        assembly {
            slot := rd.slot
            offset := rd.offset
        }
    }


   fn set_a(MyInt64 _a, MyInt64 _b) external {
       a.a = _a;
       a.b = _b;
   }

   fn set_ra(int64 _a, int64 _b) external {
       ra.a = _a;
       ra.b = _b;
   }

   fn set_b(MyInt64 _a, MyInt64 _b) external {
       b.a = _a;
       b.b = _b;
   }

   fn set_rb(int64 _a, int64 _b) external {
       rb.a = _a;
       rb.b = _b;
   }

   fn set_c(MyInt64 _a, MyInt64 _b) external {
       c.a = _a;
       c.b = _b;
   }

   fn set_rc(int64 _a, int64 _b) external {
       rc.a = _a;
       rc.b = _b;
   }

   fn set_d(MyInt96 _a, MyAddress _b) external {
       d.a = _a;
       d.b = _b;
   }

   fn set_rd(int96 _a, address _b) external {
       rd.a = _a;
       rd.b = _b;
   }

   fn read_slot(u256 slot) view external -> (u256 value) {
       assembly {
           value := sload(slot)
       }
   }

   fn read_contents_asm() external -> (bytes32 rxa, bytes32 rya, bytes32 rxb, bytes32 ryb) {
       b.a = MyInt64.wrap(-2);
       b.b = MyInt64.wrap(-3);
       HalfSlot memory x = b;
       MyInt64 y = b.a;
       MyInt64 z = b.b;
       assembly {
           rxa := mload(x)
           rya := y
           rxb := mload(add(x, 0x20))
           ryb := z
       }
   }
}

// ====
// compileViaYul: also
// ----
// storage_a() -> 0, 0
// set_a(int64,int64): 100, 200 ->
// read_slot(u256): 0 -> 0xc80000000000000064
// storage_ra() -> 1, 0
// set_ra(int64,int64): 100, 200 ->
// read_slot(u256): 1 -> 0xc80000000000000064
// storage_b() -> 2, 0
// set_b(int64,int64): 0, 200 ->
// read_slot(u256): 2 -> 3689348814741910323200
// storage_rb() -> 3, 0
// set_rb(int64,int64): 0, 200 ->
// read_slot(u256): 3 -> 3689348814741910323200
// storage_c() -> 4, 0
// set_c(int64,int64): 100, 0 ->
// read_slot(u256): 4 -> 0x64
// storage_rc() -> 5, 0
// set_rc(int64,int64): 100, 0 ->
// read_slot(u256): 5 -> 0x64
// storage_d() -> 6, 0
// set_d(int96,address): 39614081257132168796771975167, 1461501637330902918203684832716283019655932542975 ->
// read_slot(u256): 6 -> -39614081257132168796771975169
// storage_rd() -> 7, 0
// set_rd(int96,address): 39614081257132168796771975167, 1461501637330902918203684832716283019655932542975 ->
// read_slot(u256): 7 -> -39614081257132168796771975169
// read_contents_asm() -> 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe, 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe, 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd, 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd
