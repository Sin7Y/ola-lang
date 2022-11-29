contract receiver { fn pay() payable public {} }
contract test {
    fn f() public { (new receiver()).pay{value: 10}(); }
    receiver r = new receiver();
    fn h() public { r.pay{value: 10}(); }
}
// ----
