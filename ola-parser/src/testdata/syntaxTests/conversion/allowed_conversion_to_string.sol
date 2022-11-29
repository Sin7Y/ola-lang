contract C {
	string a;
	string b;
	fn f() public view {
		string storage c = a;
		string memory d = b;
		d = string(c);
	}
}
// ----
