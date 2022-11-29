struct S { mapping(uint => uint)[2] a; }
library L {
    fn f(S storage s) public {}
}
// ----
