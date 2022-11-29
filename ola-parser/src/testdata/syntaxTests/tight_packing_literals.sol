contract C {
    fn k() pure public -> (bytes memory) {
        return abi.encodePacked(1);
    }
}

// ----
// TypeError 7279: (99-100): Cannot perform packed encoding for a literal. Please convert it to an explicit type first.
