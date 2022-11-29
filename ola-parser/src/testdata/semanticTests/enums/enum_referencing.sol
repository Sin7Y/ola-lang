interface I {
    enum Direction { A, B, Left, Right }
}
library L {
    enum Direction { Left, Right }
    fn f()  -> (Direction) {
        return Direction.Right;
    }
    fn g()  -> (I.Direction) {
        return I.Direction.Right;
    }
}
contract C is I {
    fn f()  -> (Direction) {
        return Direction.Right;
    }
    fn g()  -> (I.Direction) {
        return I.Direction.Right;
    }
    fn h()  -> (L.Direction) {
        return L.Direction.Right;
    }
    fn x()  -> (L.Direction) {
        return L.f();
    }
    fn y()  -> (I.Direction) {
        return L.g();
    }
}
// ====
// compileViaYul: also
// compileToEwasm: false
// ----
// library: L
// f() -> 3
// g() -> 3
// f() -> 3
// g() -> 3
// h() -> 1
// x() -> 1
// y() -> 3
