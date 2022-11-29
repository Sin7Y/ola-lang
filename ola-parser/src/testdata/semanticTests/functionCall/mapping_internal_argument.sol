contract test {
    mapping(uint8 => uint8) a;
    mapping(uint8 => uint8) b;
    fn set_internal(mapping(uint8 => uint8) storage m, uint8 key, uint8 value) internal -> (uint8) {
        uint8 oldValue = m[key];
        m[key] = value;
        return oldValue;
    }
    fn set(uint8 key, uint8 value_a, uint8 value_b)  -> (uint8 old_a, uint8 old_b) {
        old_a = set_internal(a, key, value_a);
        old_b = set_internal(b, key, value_b);
    }
    fn get(uint8 key)  -> (uint8, uint8) {
        return (a[key], b[key]);
    }
}
// ====
// compileViaYul: also
// ----
// set(uint8,uint8,uint8): 1, 21, 42 -> 0, 0
// get(uint8): 1 -> 21, 42
// set(uint8,uint8,uint8): 1, 10, 11 -> 21, 42
// get(uint8): 1 -> 10, 11
