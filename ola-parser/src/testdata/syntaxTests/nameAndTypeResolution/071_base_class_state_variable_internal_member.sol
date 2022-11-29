contract Parent {
    uint256 internal m_aMember;
}
contract Child is Parent {
    fn foo() public returns (uint256) { return Parent.m_aMember; }
}
// ----
// Warning 2018: (83-151): fn state mutability can be restricted to view
