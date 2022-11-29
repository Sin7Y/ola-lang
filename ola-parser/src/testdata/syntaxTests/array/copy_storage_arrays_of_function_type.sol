contract C {
    fn() external [] s0;
    fn() external view [] s1;
    fn copyStorageArrayOfFunctionType() public {
        s1 = s0;
    }
}
// ----
// TypeError 7407: (148-150): Type fn () external[] storage ref is not implicitly convertible to expected type fn () view external[] storage ref.
