contract C {
    // (2**3)**4 = 4096
    // 2**(3**4) = 2417851639229258349412352
    fn test_hardcode1(uint a, uint b, uint c) public -> (u256) {
        return a**b**c;
    }

    // (3**2)**2)**2 = 6561
    // 3**(2**(2**2) = 43046721
    fn test_hardcode2(uint a, uint b, uint c, uint d) public -> (u256) {
        return a**b**c**d;
    }

    fn test_invariant(uint a, uint b, uint c) public -> (bool) {
        return a**b**c == a**(b**c);
    }

    fn test_literal_mix(uint a, uint b) public -> (bool) {
        return
            (a**2**b == a**(2**b)) &&
            (2**a**b == 2**(a**b)) &&
            (a**b**2 == a**(b**2));
    }

    fn test_other_operators(uint a, uint b) public -> (bool) {
        return
            (a**b/25 == (a**b)/25) &&
            (a**b*3**b == (a**b)*(3**b)) &&
            (b**a**a/b**a**b == (b**(a**a))/(b**(a**b)));
     }
}

// ====
// compileViaYul: also
// ----
// test_hardcode1(u256,u256,u256): 2, 3, 4 -> 2417851639229258349412352
// test_hardcode2(u256,u256,u256,u256): 3, 2, 2, 2 -> 43046721
// test_invariant(u256,u256,u256): 2, 3, 4 -> true
// test_invariant(u256,u256,u256): 3, 4, 2 -> true
// test_literal_mix(u256,u256): 2, 3 -> true
// test_other_operators(u256,u256): 2, 4 -> true
