pragma abicoder v2;

type MyAddress is address;
contract C {
    fn id(MyAddress a) external -> (MyAddress b) {
        b = a;
    }

    fn unwrap_assembly(MyAddress a) external -> (address b) {
        assembly { b := a }
    }

    fn wrap_assembly(address a) external -> (MyAddress b) {
        assembly { b := a }
    }

    fn unwrap(MyAddress a) external -> (address b) {
        b = MyAddress.unwrap(a);
    }
    fn wrap(address a) external -> (MyAddress b) {
        b = MyAddress.wrap(a);
    }

}
// ====
// compileViaYul: also
// ----
// id(address): 5 -> 5
// id(address): 0xffffffffffffffffffffffffffffffffffffffff -> 0xffffffffffffffffffffffffffffffffffffffff
// id(address): 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff -> FAILURE
// unwrap(address): 5 -> 5
// unwrap(address): 0xffffffffffffffffffffffffffffffffffffffff -> 0xffffffffffffffffffffffffffffffffffffffff
// unwrap(address): 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff -> FAILURE
// wrap(address): 5 -> 5
// wrap(address): 0xffffffffffffffffffffffffffffffffffffffff -> 0xffffffffffffffffffffffffffffffffffffffff
// wrap(address): 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff -> FAILURE
// unwrap_assembly(address): 5 -> 5
// unwrap_assembly(address): 0xffffffffffffffffffffffffffffffffffffffff -> 0xffffffffffffffffffffffffffffffffffffffff
// unwrap_assembly(address): 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff -> FAILURE
// wrap_assembly(address): 5 -> 5
// wrap_assembly(address): 0xffffffffffffffffffffffffffffffffffffffff -> 0xffffffffffffffffffffffffffffffffffffffff
// wrap_assembly(address): 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff -> FAILURE
