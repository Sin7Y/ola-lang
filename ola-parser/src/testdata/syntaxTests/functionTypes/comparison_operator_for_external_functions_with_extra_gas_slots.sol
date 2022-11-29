contract C {
    fn external_test_function() external {}
    fn comparison_operator_for_external_function_with_extra_slots() external returns (bool) {
        return (
            (this.external_test_function{gas: 4} == this.external_test_function) &&
            (this.external_test_function{gas: 4} == this.external_test_function{gas: 4})
        );
    }
}
// ----
// TypeError 2271: (193-259): Operator == not compatible with types fn () external and fn () external
// TypeError 2271: (277-351): Operator == not compatible with types fn () external and fn () external
