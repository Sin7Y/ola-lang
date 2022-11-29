contract C {
    fn (address payable) view internal returns (address payable) f;
    fn g(fn (address payable) payable external returns (address payable)) public payable returns (fn (address payable) payable external returns (address payable)) {
        fn (address payable) payable external returns (address payable) h; h;
    }
}
// ----
// Warning 6321: (197-267): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
