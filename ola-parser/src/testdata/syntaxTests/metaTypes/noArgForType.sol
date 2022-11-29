contract Test {
    fn creation()  -> (bytes memory) {
        type();
    }
}
// ----
// TypeError 8885: (85-91): This fn takes one argument, but 0 were provided.
