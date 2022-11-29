contract C {
    fn f(u256 x)  -> (u256 a) {
        assembly {
            a := byte(x, 31)
        }
    }

    fn g(u256 x)  -> (u256 a) {
        assembly {
            a := byte(31, x)
        }
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256): 2 -> 0
// g(u256): 2 -> 2
