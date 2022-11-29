contract C {
    fn f(address a) public {
        selfdestruct(a);
    }
}
// ----
// TypeError 9553: (69-70): Invalid type for argument in fn call. Invalid implicit conversion from address to address payable requested.
