==== Source: a.sol ====
fn f(u256) pure -> (u256) { return 7; }
fn f(bytes memory x) pure -> (u256) { return x.length; }
==== Source: b.sol ====
import "a.sol" as M;
contract C {
    fn f()  -> (u256, u256) {
        return (M.f(2), M.f("abc"));

    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 7, 3
