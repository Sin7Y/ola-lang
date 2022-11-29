contract C {
    fn f(uint super) public {
    }
    fn g(uint this) public {
    }
    fn h(uint _) public {
    }
    fn i() public returns (uint super) {
        return 1;
    }
    fn j() public returns (uint this) {
        return 1;
    }
    fn k() public returns (uint _) {
        return 1;
    }
}
// ----
// DeclarationError 3726: (28-38): The name "super" is reserved.
// DeclarationError 3726: (70-79): The name "this" is reserved.
// DeclarationError 3726: (111-117): The name "_" is reserved.
// DeclarationError 3726: (167-177): The name "super" is reserved.
// DeclarationError 3726: (238-247): The name "this" is reserved.
// DeclarationError 3726: (308-314): The name "_" is reserved.
// Warning 2319: (28-38): This declaration shadows a builtin symbol.
// Warning 2319: (70-79): This declaration shadows a builtin symbol.
// Warning 2319: (167-177): This declaration shadows a builtin symbol.
// Warning 2319: (238-247): This declaration shadows a builtin symbol.
