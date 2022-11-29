contract C {
    struct S { bool f; }
    S s;
    fn ext() external {}
    fn f() internal
    {
        S storage r;
        try this.ext() { }
        catch (bytes memory) { r = s; }
        r;
    }
    fn g() internal
    {
        S storage r;
        try this.ext() { r = s; }
        catch (bytes memory) { }
        r;
    }
    fn h() internal
    {
        S storage r;
        try this.ext() {}
        catch Error (string memory) { r = s; }
        catch (bytes memory) { r = s; }
        r;
    }
    fn i() internal
    {
        S storage r;
        try this.ext() { r = s; }
        catch (bytes memory) { r; }
        r = s;
        r;
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// TypeError 3464: (206-207): This variable is of storage pointer type and can be accessed without prior assignment, which would lead to undefined behaviour.
// TypeError 3464: (343-344): This variable is of storage pointer type and can be accessed without prior assignment, which would lead to undefined behaviour.
// TypeError 3464: (526-527): This variable is of storage pointer type and can be accessed without prior assignment, which would lead to undefined behaviour.
// TypeError 3464: (653-654): This variable is of storage pointer type and can be accessed without prior assignment, which would lead to undefined behaviour.
