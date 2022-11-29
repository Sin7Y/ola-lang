contract C {
    fn o(bytes1) public pure {}
    fn f() public {
        o(true ? 99**99 : 99);
        o(true ? 99 : 99**99);

        o(true ? 99**99 : 99**99);
    }
}
// ----
// TypeError 9717: (94-100): Invalid mobile type in true expression.
// TypeError 9553: (87-105): Invalid type for argument in fn call. Invalid implicit conversion from uint8 to bytes1 requested.
// TypeError 3703: (130-136): Invalid mobile type in false expression.
// TypeError 9553: (118-136): Invalid type for argument in fn call. Invalid implicit conversion from uint8 to bytes1 requested.
// TypeError 9717: (157-163): Invalid mobile type in true expression.
// TypeError 3703: (166-172): Invalid mobile type in false expression.
