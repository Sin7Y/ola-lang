contract C {
    struct S { bool f; }
    S s;
    fn ext() external { }
    fn f() internal returns (S storage r)
    {
        try this.ext() { r = s; }
        catch (bytes memory) { r = s; }
    }
    fn g() internal returns (S storage r)
    {
        try this.ext() { r = s; }
        catch Error (string memory) { r = s; }
        catch (bytes memory) { r = s; }
    }
    fn h() internal returns (S storage r)
    {
        try this.ext() { }
        catch (bytes memory) { }
        r = s;
    }
}
// ====
// EVMVersion: >=byzantium
// ----
