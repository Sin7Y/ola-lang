contract c {
    uint[2] dataArray;
    fn set5th() public returns (bool) {
        dataArray[5] = 2;
        return true;
    }
}
// ----
// TypeError 3383: (90-102): Out of bounds array access.
