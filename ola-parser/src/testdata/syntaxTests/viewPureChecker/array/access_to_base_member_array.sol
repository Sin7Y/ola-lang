contract A {
    u256[] x;
}

contract B is A {
    fn g()  -> (u256) {
        return A.x.length;
    }
    fn h()  -> (u256) {
        return A.x[2];
    }
}
// ----
// TypeError 2527: (109-112): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (109-119): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (188-191): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (188-194): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
