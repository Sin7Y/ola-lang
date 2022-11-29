contract B {
    fn f() mod1(true)  { }
    modifier mod1(u256 a) { if (a > 0) _; }
}
// ----
// TypeError 4649: (35-39): Invalid type for argument in modifier invocation. Invalid implicit conversion from bool to u256 requested.
