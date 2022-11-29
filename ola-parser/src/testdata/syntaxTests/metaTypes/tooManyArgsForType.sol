contract Test {
    fn creation()  -> (bytes memory) {
        type(1, 2);
    }
}
// ----
// TypeError 8885: (85-95): This fn takes one argument, but 2 were provided.
