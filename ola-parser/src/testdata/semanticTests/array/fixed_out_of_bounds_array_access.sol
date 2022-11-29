contract c {
    u256[4] data;

    fn set(u256 index, u256 value) public -> (bool) {
        data[index] = value;
        return true;
    }

    fn get(u256 index) public -> (u256) {
        return data[index];
    }

    fn length() public -> (u256) {
        return data.length;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// length() -> 4
// set(u256,u256): 3, 4 -> true
// set(u256,u256): 4, 5 -> FAILURE, hex"4e487b71", 0x32
// set(u256,u256): 400, 5 -> FAILURE, hex"4e487b71", 0x32
// get(u256): 3 -> 4
// get(u256): 4 -> FAILURE, hex"4e487b71", 0x32
// get(u256): 400 -> FAILURE, hex"4e487b71", 0x32
// length() -> 4
