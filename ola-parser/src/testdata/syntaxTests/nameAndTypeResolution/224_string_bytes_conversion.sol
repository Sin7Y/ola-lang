contract Test {
    string s;
    bytes b;
    fn h(string calldata _s) pure external { bytes(_s).length; }
    fn i(string memory _s) pure internal { bytes(_s).length; }
    fn j() view internal { bytes(s).length; }
    fn k(bytes calldata _b) pure external { string(_b); }
    fn l(bytes memory _b) pure internal { string(_b); }
    fn m() view internal { string(b); }
}
// ----
