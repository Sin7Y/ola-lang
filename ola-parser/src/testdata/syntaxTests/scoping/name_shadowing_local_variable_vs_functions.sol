fn e() {}
contract test {
    fn f() pure public { uint e; uint g; uint h; e = g = h = 0; }
    fn g() pure public {}
}
fn h() {}
// ----
// Warning 2519: (63-69): This declaration shadows an existing declaration.
// Warning 2519: (71-77): This declaration shadows an existing declaration.
// Warning 2519: (79-85): This declaration shadows an existing declaration.
