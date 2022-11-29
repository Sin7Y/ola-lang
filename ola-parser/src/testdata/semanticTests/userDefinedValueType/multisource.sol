==== Source: A ====
type MyInt is int;
type MyAddress is address;
==== Source: B ====
import {MyInt, MyAddress as OurAddress} from "A";
contract A {
    fn f(int x) external view ->(MyInt) { return MyInt.wrap(x); }
    fn f(address x) external view ->(OurAddress) { return OurAddress.wrap(x); }
}
// ====
// compileViaYul: also
// ----
// f(int256): 5 -> 5
// f(address): 1 -> 1
