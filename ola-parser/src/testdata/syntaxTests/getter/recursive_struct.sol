contract C {
    struct Y {
        Y[] x;
    }
    mapping(u256 => Y) m;
}
// ----
// TypeError 6744: (53-83): Internal or recursive type is not allowed for  state variables.
