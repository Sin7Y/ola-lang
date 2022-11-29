contract C {
    struct S { u256 x; }
    S s;
    fn e()   {
        assembly { mstore(keccak256(0, 20), mul(s.slot, 2)) }
    }
    fn f()   {
        u256 x;
        assembly { x := 7 }
    }
    fn g() view  {
        assembly { for {} 1 { pop(sload(0)) } { } pop(gas()) }
    }
    fn h() view  {
        assembly { fn g() { pop(blockhash(20)) } }
    }
    fn i()  {
        assembly { pop(call(0, 1, 2, 3, 4, 5, 6)) }
    }
    fn j()  {
        assembly { pop(call(gas(), 1, 2, 3, 4, 5, 6)) }
    }
    fn k()  {
        assembly { pop(balance(0)) }
    }
    fn l()  {
        assembly { pop(extcodesize(0)) }
    }
}
// ----
