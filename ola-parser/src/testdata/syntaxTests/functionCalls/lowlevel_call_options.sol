contract C {
    fn foo() internal {
        (bool success, ) = address(10).call{value: 7, gas: 3}("");
        success;
    }
}
// ----
