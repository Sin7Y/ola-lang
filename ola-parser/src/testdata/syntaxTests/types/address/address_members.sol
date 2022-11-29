contract C {
    fn f() public view returns (address) { return address(this); }
    fn g() public view returns (uint) { return f().balance; }
    fn h() public view returns (bytes memory) { return f().code; }
    fn i() public view returns (uint) { return f().code.length; }
    fn j() public view returns (uint) { return h().length; }
}
// ----
