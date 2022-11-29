contract C {
    fn f()  {}
}
fn fun() {
    C.f();
}
// ----
// TypeError 3419: (68-73): Cannot call fn via contract type name.
