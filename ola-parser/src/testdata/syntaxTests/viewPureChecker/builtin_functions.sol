contract C {
    fn f()  {
        payable(this).transfer(1);
        require(payable(this).send(2));
        selfdestruct(payable(this));
        (bool success,) = address(this).delegatecall("");
        require(success);
		(success,) = address(this).call("");
        require(success);
    }
    fn g()   {
        bytes32 x = keccak256("abc");
        bytes32 y = sha256("abc");
        address z = ecrecover(bytes32(u256(1)), uint8(2), bytes32(u256(3)), bytes32(u256(4)));
        require(true);
        assert(true);
        x; y; z;
    }
    receive() payable external {}
}
// ----
