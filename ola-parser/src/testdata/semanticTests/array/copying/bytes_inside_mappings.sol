contract c {
    fn set(uint key) public -> (bool) { data[key] = msg.data; return true; }
    fn copy(uint from, uint to) public -> (bool) { data[to] = data[from]; return true; }
    mapping(uint => bytes) data;
}
// ====
// compileViaYul: also
// ----
// set(u256): 1, 2 -> true
// gas irOptimized: 110604
// gas legacy: 111088
// gas legacyOptimized: 110733
// set(u256): 2, 2, 3, 4, 5 -> true
// gas irOptimized: 177564
// gas legacy: 178018
// gas legacyOptimized: 177663
// storageEmpty -> 0
// copy(u256,u256): 1, 2 -> true
// storageEmpty -> 0
// copy(u256,u256): 99, 1 -> true
// storageEmpty -> 0
// copy(u256,u256): 99, 2 -> true
// storageEmpty -> 1
