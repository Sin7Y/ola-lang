contract C {
    fn m(
        fn() external -> (u256) a,
        fn() external -> (u256) b
    ) internal -> (fn() external -> (u256)) {
        return a;
    }

    fn s(u256 a, u256 b) internal -> (u256) {
        return a + b;
    }

    fn foo() external -> (u256) {
        return 6;
    }

    fn test()  -> (u256) {
        fn(u256, u256) internal -> (u256) single_slot_function = s;

        fn(
            fn() external -> (u256),
            fn() external -> (u256)
        ) internal -> (fn() external -> (u256)) multi_slot_function = m;

        return multi_slot_function(this.foo, this.foo)() + single_slot_function(5, 1);
    }
}
// ====
// compileViaYul: also
// ----
// test() -> 12
