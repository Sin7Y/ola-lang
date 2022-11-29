type MyAddress is address;
interface I {}
contract C {
    fn f(MyAddress a) external {
    }
    fn f(address a) external {
    }
}
contract D {
    fn g(MyAddress a) external {
    }
}
contract E is D {
    fn g(I a) external {
    }
}
// ----
// TypeError 9914: (104-142): fn overload clash during conversion to external types for arguments.
// TypeError 9914: (162-202): fn overload clash during conversion to external types for arguments.
