contract C {
    fn f(uint size) public {
        uint[] memory x = new uint[]();
    }
}
// ----
// TypeError 6160: (74-86): Wrong argument count for fn call: 0 arguments given but expected 1.
