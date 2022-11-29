contract C {
    fn(uint) returns (bool ret) f;
}
// ----
// SyntaxError 7304: (41-49): Return parameters in fn types may not be named.
