contract Test {
    struct RecursiveStruct {
        RecursiveStruct[] vals;
    }

    fn func() private pure {
        RecursiveStruct[1] memory val;
        val;
    }
}
// ----
