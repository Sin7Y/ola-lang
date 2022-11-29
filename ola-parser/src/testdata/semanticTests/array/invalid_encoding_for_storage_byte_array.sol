contract C {
    bytes  x = "abc";
    bytes  y;
    fn invalidateXShort()  {
        assembly { sstore(x.slot, 64) }
        delete y;
    }
    fn invalidateXLong()  {
        assembly { sstore(x.slot, 5) }
        delete y;
    }
    fn abiEncode()  -> (bytes memory) { return x; }
    fn abiEncodePacked()  -> (bytes memory) { return abi.encodePacked(x); }
    fn copyToMemory()  -> (bytes memory m) { m = x; }
    fn indexAccess()  -> (bytes1) { return x[0]; }
    fn assignTo()  { x = "def"; }
    fn assignToLong()  { x = "1234567890123456789012345678901234567"; }
    fn copyToStorage()  { y = x; }
    fn copyFromStorageShort()  { y = "abc"; x = y; }
    fn copyFromStorageLong()  { y = "1234567890123456789012345678901234567"; x = y; }
    fn arrayPop()  { x.pop(); }
    fn arrayPush()  { x.push("t"); }
    fn arrayPushEmpty()  { x.push(); }
    fn del()  { delete x; }
}
// ====
// compileViaYul: also
// ----
// x() -> 0x20, 3, 0x6162630000000000000000000000000000000000000000000000000000000000
// abiEncode() -> 0x20, 3, 0x6162630000000000000000000000000000000000000000000000000000000000
// abiEncodePacked() -> 0x20, 3, 0x6162630000000000000000000000000000000000000000000000000000000000
// copyToMemory() -> 0x20, 3, 0x6162630000000000000000000000000000000000000000000000000000000000
// indexAccess() -> 0x6100000000000000000000000000000000000000000000000000000000000000
// arrayPushEmpty()
// arrayPush()
// x() -> 0x20, 5, 0x6162630074000000000000000000000000000000000000000000000000000000
// arrayPop()
// assignToLong()
// x() -> 0x20, 0x25, 0x3132333435363738393031323334353637383930313233343536373839303132, 0x3334353637000000000000000000000000000000000000000000000000000000
// assignTo()
// x() -> 0x20, 3, 0x6465660000000000000000000000000000000000000000000000000000000000
// copyFromStorageShort()
// x() -> 0x20, 3, 0x6162630000000000000000000000000000000000000000000000000000000000
// copyFromStorageLong()
// x() -> 0x20, 0x25, 0x3132333435363738393031323334353637383930313233343536373839303132, 0x3334353637000000000000000000000000000000000000000000000000000000
// copyToStorage()
// x() -> 0x20, 0x25, 0x3132333435363738393031323334353637383930313233343536373839303132, 0x3334353637000000000000000000000000000000000000000000000000000000
// y() -> 0x20, 0x25, 0x3132333435363738393031323334353637383930313233343536373839303132, 0x3334353637000000000000000000000000000000000000000000000000000000
// del()
// x() -> 0x20, 0x00
// invalidateXLong()
// x() -> FAILURE, hex"4e487b71", 0x22
// abiEncode() -> FAILURE, hex"4e487b71", 0x22
// abiEncodePacked() -> FAILURE, hex"4e487b71", 0x22
// copyToMemory() -> FAILURE, hex"4e487b71", 0x22
// indexAccess() -> FAILURE, hex"4e487b71", 0x22
// arrayPushEmpty() -> FAILURE, hex"4e487b71", 0x22
// arrayPush() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// arrayPop() -> FAILURE, hex"4e487b71", 0x22
// assignToLong() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// assignTo() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// copyFromStorageShort() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// copyFromStorageLong() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// copyToStorage() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// y() -> 0x20, 0x00
// del() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// invalidateXShort()
// x() -> FAILURE, hex"4e487b71", 0x22
// abiEncode() -> FAILURE, hex"4e487b71", 0x22
// abiEncodePacked() -> FAILURE, hex"4e487b71", 0x22
// copyToMemory() -> FAILURE, hex"4e487b71", 0x22
// indexAccess() -> FAILURE, hex"4e487b71", 0x22
// arrayPushEmpty() -> FAILURE, hex"4e487b71", 0x22
// arrayPush() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// arrayPop() -> FAILURE, hex"4e487b71", 0x22
// assignToLong() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// assignTo() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// copyFromStorageShort() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// copyFromStorageLong() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// copyToStorage() -> FAILURE, hex"4e487b71", 0x22
// x() -> FAILURE, hex"4e487b71", 0x22
// y() -> 0x20, 0x00
