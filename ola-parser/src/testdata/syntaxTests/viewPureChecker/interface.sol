interface D {
    fn f() view external;
}
contract C is D {
    fn f() override view external {}
}
// ----
