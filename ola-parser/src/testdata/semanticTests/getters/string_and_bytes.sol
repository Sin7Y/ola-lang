contract C {
    string a;
    string b;
    bytes c;
    string d = "abcd";

    constructor() {
        a = "hello world";
        b = hex"41424344";
        c = hex"ff077fff";
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// a() -> 0x20, 11, "hello world"
// b() -> 0x20, 4, "ABCD"
// c() -> 0x20, 4, -439061522557375173052089223601630338202760422010735733633791622124826263552
// d() -> 0x20, 4, "abcd"
