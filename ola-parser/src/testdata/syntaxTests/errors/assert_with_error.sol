error E();
fn f() pure {
    assert(E());
}
// ----
// TypeError 9553: (42-45): Invalid type for argument in fn call. Invalid implicit conversion from tuple() to bool requested.
