contract A {
    enum Foo {
        First,
        Second
    }

    fn a() public {
        A.Foo;
    }
}
// ----
// Warning 2018: (69-111): fn state mutability can be restricted to pure
