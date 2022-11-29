==== Source: A ====
struct S { u256 x; }
fn set(S storage a, u256 v) { a.x = v; }

==== Source: B ====
import "A";
import "A" as A;
contract C {
  A.S data;
  fn f(u256 v)  -> (u256 one, u256 two) {
    A.set(data, v);
    one = data.x;
    set(data, v + 1);
    two = data.x;
  }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256): 7 -> 7, 8
