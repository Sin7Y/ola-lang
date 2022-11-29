contract A {
    fallback (bytes calldata _input) external -> (bytes memory) {
        return _input;
    }
}
contract B {
    fallback (bytes calldata _input) external -> (bytes memory) {
        return "xyz";
    }
}
contract C is B, A {
     fn f()  -> (bool, bytes memory) {
        (bool success, bytes memory retval) = address(this).call("abc");
        return (success, retval);
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// TypeError 6480: (229-420): Derived contract must override fn "". Two or more base classes define fn with same name and parameter types.
