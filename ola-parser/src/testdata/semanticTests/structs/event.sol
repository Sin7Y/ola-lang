pragma abicoder v2;

struct Item {uint x;}
library L {
    event Ev(Item);
    fn o() public { emit L.Ev(Item(1)); }
}
contract C {
    fn f() public {
        L.o();
    }
}
// ====
// compileViaYul: also
// ----
// library: L
// f() ->
// ~ emit Ev((u256)): 0x01
