contract C {
    struct S { bool f; }
    S s;
    fn ext() external { }
    fn f() internal
    {
        S storage r;
        try this.ext() { r = s; }
        catch (bytes memory) { r = s; }
        r;
    }
    fn g() internal
    {
        S storage r;
        try this.ext() { r = s; }
        catch Error (string memory) { r = s; }
        catch (bytes memory) { r = s; }
        r;
    }
    fn h() internal
    {
        S storage r;
        try this.ext() { }
        catch (bytes memory) { }
        r = s;
        r;
    }
}
// ====
// EVMVersion: >=byzantium
// ----
