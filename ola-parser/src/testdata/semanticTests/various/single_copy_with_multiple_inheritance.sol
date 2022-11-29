contract Base {
    u256 data;

    fn setData(u256 i)  {
        data = i;
    }

    fn getViaBase()  -> (u256 i) {
        return data;
    }
}


contract A is Base {
    fn setViaA(u256 i)  {
        setData(i);
    }
}


contract B is Base {
    fn getViaB()  -> (u256 i) {
        return getViaBase();
    }
}


contract Derived is Base, B, A {}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// getViaB() -> 0
// setViaA(u256): 23 ->
// getViaB() -> 23
