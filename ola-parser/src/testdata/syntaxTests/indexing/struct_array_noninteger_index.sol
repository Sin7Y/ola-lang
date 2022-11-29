contract test {
    struct s { u256 a; u256 b;}
    fn f()   -> (bytes1) {
        s[75555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555];
        s[7];
    }
}

// ----
// TypeError 7407: (106-246): Type int_const 7555...(132 digits omitted)...5555 is not implicitly convertible to expected type u256. Literal is too large to fit in u256.
