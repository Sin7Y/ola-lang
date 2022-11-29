contract C {
    fn f(address) public pure {}
    fn f(address payable) public pure {}

}
// ----
// TypeError 9914: (56-98): fn overload clash during conversion to external types for arguments.
