contract C {
    fn f() view  {
        bytes32 x = keccak256("abc");
        bytes32 y = sha256("abc");
        address z = ecrecover(bytes32(u256(1)), uint8(2), bytes32(u256(3)), bytes32(u256(4)));
        require(true);
        assert(true);
        x; y; z;
    }
    fn g()  {
        bytes32 x = keccak256("abc");
        bytes32 y = sha256("abc");
        address z = ecrecover(bytes32(u256(1)), uint8(2), bytes32(u256(3)), bytes32(u256(4)));
        require(true);
        assert(true);
        x; y; z;
    }
}
// ----
// Warning 2018: (17-288): fn state mutability can be restricted to pure
// Warning 2018: (293-559): fn state mutability can be restricted to pure
