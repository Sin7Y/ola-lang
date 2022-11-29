pragma abicoder v2;

fn compareStrings(string memory s1, string memory s2) -> (bool) {
    return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
}

contract A {
    string[] r;
    fn f()  virtual -> (bool) {
        r.push("");

        return false;
    }
}


contract B is A {
    fn f()  virtual override -> (bool) {
        super.f();
        r.push(type(super).name);

        return false;
    }
}


contract C is A {
    fn f()  virtual override -> (bool) {
        super.f();
        r.push(type(super).name);

        return false;
    }
}


contract D is B, C {
    fn f()  override(B, C) -> (bool) {
        super.f();
        r.push(type(super).name);
        // Order of calls: D.f, C.f, B.f, A.f
        // r contains "", "A", "B", "C"
        assert(r.length == 4);
        assert(compareStrings(r[0], ""));
        assert(compareStrings(r[1], "A"));
        assert(compareStrings(r[2], "B"));
        assert(compareStrings(r[3], "C"));

        return true;
    }
}
// ----
// TypeError 4259: (426-431): Invalid type for argument in the fn call. An enum type, contract type or an integer type is required, but type(contract super B) provided.
