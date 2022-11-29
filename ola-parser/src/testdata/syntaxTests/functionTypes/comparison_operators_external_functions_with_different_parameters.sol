contract C {
    fn external_test_function1(uint num) external {}
    fn external_test_function2(bool val) external {}

    fn comparison_operator_between_internal_and_external_function_pointers() external returns (bool) {
        fn () external external_function_pointer_local1 = this.external_test_function1;
        fn () external external_function_pointer_local2 = this.external_test_function2;

        assert(
            this.external_test_function1 == external_function_pointer_local1 &&
            this.external_test_function2 == external_function_pointer_local2
        );
        assert(
            external_function_pointer_local2 != external_function_pointer_local1 &&
            this.external_test_function2 != this.external_test_function1
        );

        return true;
    }
}
// ----
// TypeError 9574: (249-333): Type fn (uint256) external is not implicitly convertible to expected type fn () external.
// TypeError 9574: (343-427): Type fn (bool) external is not implicitly convertible to expected type fn () external.
// TypeError 2271: (458-522): Operator == not compatible with types fn (uint256) external and fn () external
// TypeError 2271: (538-602): Operator == not compatible with types fn (bool) external and fn () external
// TypeError 2271: (726-786): Operator != not compatible with types fn (bool) external and fn (uint256) external
