contract C {
    fn f(address) external pure {}
    fn f(address payable) external pure {}

}
// ----
// TypeError 9914: (58-102): fn overload clash during conversion to external types for arguments.
