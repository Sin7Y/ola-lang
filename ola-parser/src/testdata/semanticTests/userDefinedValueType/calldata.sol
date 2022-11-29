pragma abicoder v2;
type MyAddress is address;

contract C {
    MyAddress[]  addresses;
    fn f(MyAddress[] calldata _addresses) external {
        for (u256 i = 0; i < _addresses.length; i++) {
            MyAddress.unwrap(_addresses[i]).call("");
        }
        addresses = _addresses;
    }
    fn g(MyAddress[] memory _addresses) external {
        for (u256 i = 0; i < _addresses.length; i++) {
            MyAddress.unwrap(_addresses[i]).call("");
        }
        addresses = _addresses;
    }
    fn test_f() external -> (bool) {
        clean();
        MyAddress[] memory test = new MyAddress[](3);
        test[0] = MyAddress.wrap(address(21));
        test[1] = MyAddress.wrap(address(22));
        test[2] = MyAddress.wrap(address(23));
        this.f(test);
        test_equality(test);
        return true;
    }
    fn test_g() external -> (bool) {
        clean();
        MyAddress[] memory test = new MyAddress[](5);
        test[0] = MyAddress.wrap(address(24));
        test[1] = MyAddress.wrap(address(25));
        test[2] = MyAddress.wrap(address(26));
        test[3] = MyAddress.wrap(address(27));
        test[4] = MyAddress.wrap(address(28));
        this.g(test);
        test_equality(test);
        return true;
    }
    fn clean() internal {
        delete addresses;
    }
    fn test_equality(MyAddress[] memory _addresses) internal view {
        require (_addresses.length == addresses.length);
        for (u256 i = 0; i < _addresses.length; i++) {
            require(MyAddress.unwrap(_addresses[i]) == MyAddress.unwrap(addresses[i]));
        }
    }
}
// ====
// compileViaYul: also
// ----
// test_f() -> true
// gas irOptimized: 122329
// gas legacy: 126150
// gas legacyOptimized: 123163
// test_g() -> true
// gas irOptimized: 95980
// gas legacy: 101281
// gas legacyOptimized: 96566
// addresses(u256): 0 -> 0x18
// addresses(u256): 1 -> 0x19
// addresses(u256): 3 -> 0x1b
// addresses(u256): 4 -> 0x1c
// addresses(u256): 5 -> FAILURE
