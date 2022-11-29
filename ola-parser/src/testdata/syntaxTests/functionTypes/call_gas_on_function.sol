contract C {
    fn (uint) external returns (uint) x;
    fn f() public {
        x{gas: 2}(1);
    }
}

// ----
