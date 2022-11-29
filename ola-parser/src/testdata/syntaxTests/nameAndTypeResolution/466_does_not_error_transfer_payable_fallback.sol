// This used to be a test for a.transfer to generate a warning
// because A does not have a payable fallback fn.

contract A {
    receive() external payable {}
}

contract B {
    A a;

    fallback() external {
        payable(a).transfer(100);
    }
}
// ----
