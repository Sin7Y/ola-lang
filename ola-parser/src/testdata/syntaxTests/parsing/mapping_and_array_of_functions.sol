contract test {
    mapping (address => fn() internal returns (uint)) a;
    mapping (address => fn() external) b;
    mapping (address => fn() external[]) c;
    fn() external[] d;
}
// ----
