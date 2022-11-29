contract root { fn rootFunction() public {} }
contract inter1 is root { fn f() public virtual {} }
contract inter2 is root { fn f() public virtual {} }
contract derived is root, inter2, inter1 {
	fn g() public { f(); rootFunction(); }
	fn f() override(inter1, inter2) public {}
}
// ----
