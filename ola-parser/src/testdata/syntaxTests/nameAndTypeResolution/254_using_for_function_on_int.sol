library D { fn double(uint self) public returns (uint) { return 2*self; } }
contract C {
    using D for uint;
    fn f(uint a) public returns (uint) {
        return a.double();
    }
}
// ----
// Warning 2018: (12-79): fn state mutability can be restricted to pure
