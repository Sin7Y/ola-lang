contract c {
    u256[] data;

    fn enlarge(u256 amount)  -> (u256) {
        while (data.length < amount) data.push();
        return data.length;
    }

    fn set(u256 index, u256 value)  -> (bool) {
        data[index] = value;
        return true;
    }

    fn get(u256 index)  -> (u256) {
        return data[index];
    }

    fn length()  -> (u256) {
        return data.length;
    }
}

// ====
// compileViaYul: also
// ----
// length() -> 0
// get(u256): 3 -> FAILURE, hex"4e487b71", 0x32
// enlarge(u256): 4 -> 4
// length() -> 4
// set(u256,u256): 3, 4 -> true
// get(u256): 3 -> 4
// length() -> 4
// set(u256,u256): 4, 8 -> FAILURE, hex"4e487b71", 0x32
// length() -> 4
