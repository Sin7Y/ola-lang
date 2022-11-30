contract test {
    u256  data;

    fn c() {
        data = 8;
    }

    u256 super_secret_data;
}
// ====
// allowNonExistingFunctions: true
// compileToEwasm: also
// compileViaYul: also
// ----
// data() -> 8
// name() -> "Celina"
// a_hash() -> 0xa91eddf639b0b768929589c1a9fd21dcb0107199bdd82e55c5348018a1572f52
// an_address() -> 0x1337
// super_secret_data() -> FAILURE
