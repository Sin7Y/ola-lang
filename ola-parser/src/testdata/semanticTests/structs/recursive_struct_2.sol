contract C {
    struct S {
        uint16 v;
        S[] x;
    }
    uint8[77] padding;
    S s;
    constructor() {
         s.v = 21;
         s.x.push(); s.x.push(); s.x.push();
         s.x[0].v = 101; s.x[1].v = 102; s.x[2].v = 103;
    }
    fn f() public -> (u256 a, u256 b, u256 c, u256 d) {
       S storage sptr1 = s.x[0];
       S storage sptr2 = s.x[1];
       S storage sptr3 = s.x[2];
       u256 slot1; u256 slot2; u256 slot3;
       assembly { slot1 := sptr1.slot slot2 := sptr2.slot slot3 := sptr3.slot }
       delete s;
       assembly { a := sload(s.slot) b := sload(slot1) c := sload(slot2) d := sload(slot3) }
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 0, 0, 0, 0
