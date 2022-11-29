contract Foo {
    fn test()  {
        try this.f() {}
        catch Error(string reason) {}
    }

    fn f()  {
    }
}
// ----
// TypeError 6651: (88-101): Data location must be "memory" for parameter in fn, but none was given.
