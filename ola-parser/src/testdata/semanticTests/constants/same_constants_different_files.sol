==== Source: s1.sol ====


u256 constant a = 89;

fn fre() pure -> (u256) {
    return a;
}

==== Source: s2.sol ====

import {a as b, fre} from "s1.sol";
import "s1.sol" as M;

u256 constant a = 13;

contract C {
    fn f()  -> (u256, u256, u256, u256) {
        return (a, fre(), M.a, b);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0x0d, 0x59, 0x59, 0x59
