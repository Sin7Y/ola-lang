contract Bar {
    fn example() public {
        foo();
        return;
    }

    fn foo() internal {
        Foo.nop();
    }
}

contract Y is Bar {}

library Foo {
    fn nop() internal {}
}
