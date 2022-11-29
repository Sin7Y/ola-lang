contract c {
    fn set()  -> (bool) { data = msg.data; return true; }
    fn checkIfDataIsEmpty()  -> (bool) { return data.length == 0; }
    fn sendMessage()  -> (bool, bytes memory) { bytes memory emptyData; return address(this).call(emptyData);}
    fallback() external { data = msg.data; }
    bytes data;
}
// ====
// EVMVersion: >=byzantium
// compileToEwasm: false
// compileViaYul: also
// ----
// (): 1, 2, 3, 4, 5 ->
// gas irOptimized: 155170
// gas legacy: 155249
// gas legacyOptimized: 155212
// checkIfDataIsEmpty() -> false
// sendMessage() -> true, 0x40, 0
// checkIfDataIsEmpty() -> true
