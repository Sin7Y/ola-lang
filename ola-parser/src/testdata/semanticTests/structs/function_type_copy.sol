pragma abicoder v2;
struct S {
    fn () external[] functions;
}

contract C {
    fn f(fn () external[] calldata functions) external -> (S memory) {
        S memory s;
        s.functions = functions;
        return s;
    }
}

contract Test {
    C immutable c = new C();

    fn test() external -> (bool) {
        fn() external[] memory functions = new fn() external[](3);

        functions[0] = this.random1;
        functions[1] = this.random2;
        functions[2] = this.random3;

        S memory ret = c.f(functions);

        assert(ret.functions.length == 3);
        assert(ret.functions[0] == this.random1);
        assert(ret.functions[1] == this.random2);
        assert(ret.functions[2] == this.random3);

        return true;
    }
    fn random1() external {
    }
    fn random2() external {
    }
    fn random3() external {
    }
}
// ====
// EVMVersion: >homestead
// compileViaYul: also
// ----
// test() -> true
