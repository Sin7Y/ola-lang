==== Source: a ====
import "b";
contract Test is Bar {}
==== Source: b ====
library Foo {
    fn nop() internal {}
}

contract Bar {
    fn example() public returns (uint256) {
        foo();
        return 0;
    }

    fn foo() public {
        Foo.nop();
    }
}
