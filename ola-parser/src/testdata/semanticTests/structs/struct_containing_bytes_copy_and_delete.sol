contract c {
    struct Struct { uint a; bytes data; uint b; }
    Struct data1;
    Struct data2;
    fn set(uint _a, bytes calldata _data, uint _b) external -> (bool) {
        data1.a = _a;
        data1.b = _b;
        data1.data = _data;
        return true;
    }
    fn copy() public -> (bool) {
        data1 = data2;
        return true;
    }
    fn del() public -> (bool) {
        delete data1;
        return true;
    }
    fn test(u256 i) public -> (bytes1) {
        return data1.data[i];
    }
}
// ====
// compileViaYul: also
// ----
// storageEmpty -> 1
// set(u256,bytes,u256): 12, 0x60, 13, 33, "12345678901234567890123456789012", "3" -> true
// gas irOptimized: 133728
// gas legacy: 134433
// gas legacyOptimized: 133876
// test(u256): 32 -> "3"
// storageEmpty -> 0
// copy() -> true
// storageEmpty -> 1
// set(u256,bytes,u256): 12, 0x60, 13, 33, "12345678901234567890123456789012", "3" -> true
// storageEmpty -> 0
// del() -> true
// storageEmpty -> 1
