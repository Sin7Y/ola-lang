contract C {
    uint[] m_x;
    fn f() public view {
        uint[] storage x = m_x;
        uint[] memory y;
        x;y;
    }
}
// ----
