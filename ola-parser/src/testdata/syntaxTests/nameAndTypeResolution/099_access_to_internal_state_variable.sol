contract c {
    uint public a;
}
contract d {
    fn g() public { c(address(0)).a(); }
}
// ----
// Warning 2018: (51-93): fn state mutability can be restricted to view
