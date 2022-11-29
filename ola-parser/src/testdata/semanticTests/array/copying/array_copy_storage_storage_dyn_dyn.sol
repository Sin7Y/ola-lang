
contract c {
    uint[] data1;
    uint[] data2;
    fn setData1(uint length, uint index, uint value) public {
        data1 = new uint[](length);
        if (index < length)
            data1[index] = value;
    }
    fn copyStorageStorage() public { data2 = data1; }
    fn getData2(uint index) public -> (uint len, uint val) {
        len = data2.length; if (index < len) val = data2[index];
    }
}
// ====
// compileViaYul: also
// ----
// setData1(u256,u256,u256): 10, 5, 4 ->
// copyStorageStorage() ->
// gas irOptimized: 111387
// gas legacy: 109278
// gas legacyOptimized: 109268
// getData2(u256): 5 -> 10, 4
// setData1(u256,u256,u256): 0, 0, 0 ->
// copyStorageStorage() ->
// getData2(u256): 0 -> 0, 0
// storageEmpty -> 1
