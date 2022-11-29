library super {
    fn f() public {
    }
}

library this {
    fn f() public {
    }
}
library _ {
    fn f() public {
    }
}

contract C {
    // These are not errors
    using super for uint;
    using this for uint16;
    using _ for int;
}
// ----
// DeclarationError 3726: (0-49): The name "super" is reserved.
// DeclarationError 3726: (51-99): The name "this" is reserved.
// DeclarationError 3726: (100-145): The name "_" is reserved.
// Warning 2319: (0-49): This declaration shadows a builtin symbol.
// Warning 2319: (51-99): This declaration shadows a builtin symbol.
