contract C {
    bytes  s = "abc";
    bytes  s1 = "abcd";
    fn f()  {
        s = "abcd";
        s1 = "abc";
    }
    fn g()  {
        (s, s1) = ("abc", "abcd");
    }
}
// ====
// compileViaYul: also
// ----
// s() -> 0x20, 3, "abc"
// s1() -> 0x20, 4, "abcd"
// f() ->
// s() -> 0x20, 4, "abcd"
// s1() -> 0x20, 3, "abc"
// g() ->
// s() -> 0x20, 3, "abc"
// s1() -> 0x20, 4, "abcd"
