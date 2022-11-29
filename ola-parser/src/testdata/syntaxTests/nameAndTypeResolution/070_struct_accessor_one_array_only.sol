contract test {
    struct Data {
        u256[15] m_array;
    }
    Data data;
}
// ----
// TypeError 5359: (58-74): The struct has all its members omitted, therefore the getter cannot return any values.
