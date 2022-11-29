contract D {
    constructor(fn() external returns (uint)) {
    }
}

contract E {
    fn test(fn() external returns(uint) f) public returns (uint) {
        return f();
    }
}

library L {
    fn test(fn() external returns(uint) f) public returns (uint) {
        return f();
    }
}

contract C {
    uint x;
    // tests for usage as constructor parameter
    fn f() public {
        // An assert used to fail in ABIFunction.cpp that the fn types are not exactly equal
        // that is pure or view v/s default even though they could be converted.
        new D(this.testPure);
        new D(this.testView);
        new D(this.testDefault);
    }

    // tests for usage as contract fn parameter
    fn g() public {
        E e = E(address(0));

        e.test(this.testPure);
        e.test(this.testView);
        e.test(this.testDefault);
    }

    // tests for usage as library fn parameter
    fn h() public {
        L.test(this.testPure);
        L.test(this.testView);
        L.test(this.testDefault);
    }

    // tests for usage as return parameter
    fn i() public view returns (fn() external returns(uint)) {
        uint value = block.number % 3;

        if (value == 0) {
            return this.testPure;
        }
        else if (value == 1) {
            return this.testView;
        }
        else {
            return this.testDefault;
        }
    }

    modifier mod(fn() external returns(uint) fun) {
        if (fun() == 0) {
            _;
        }
    }

    // tests for usage as modifier parameter
    fn j(fn() external pure returns(uint) fun) mod(fun) public {
    }

    fn testPure() public pure returns (uint) {
        return 0;
    }

    fn testView() public view returns (uint) {
        return x;
    }

    fn testDefault() public returns (uint) {
        x = 5;
        return x;
    }
}
// ----
