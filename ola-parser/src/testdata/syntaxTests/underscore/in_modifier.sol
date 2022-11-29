contract C {
    modifier m() {
        _;
    }

    modifier n() {
        string memory _ = "";
        _;
        revert(_);
    }

    fn f() m() public {
    }

    fn g() n() public {
    }
}
// ----
// DeclarationError 3726: (77-92): The name "_" is reserved.
