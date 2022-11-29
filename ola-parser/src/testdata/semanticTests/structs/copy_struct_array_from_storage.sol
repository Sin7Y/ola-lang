pragma abicoder v2;

struct S { u256 value; }

contract Test {
    S[][] a;
    S[] b;

    constructor() {
        a.push();
        a[0].push(S(1));
        a[0].push(S(2));
        a[0].push(S(3));

        b.push(S(4));
        b.push(S(5));
        b.push(S(6));
        b.push(S(7));
    }

    fn test1() external -> (bool) {
        a.push();
        a[1] = b;

        assert(a.length == 2);
        assert(a[0].length == 3);
        assert(a[1].length == 4);
        assert(a[1][0].value == 4);
        assert(a[1][1].value == 5);
        assert(a[1][2].value == 6);
        assert(a[1][3].value == 7);

        return true;
    }

    fn test2() external -> (bool) {
        S[][] memory temp = new S[][](2);

        temp = a;

        assert(temp.length == 2);
        assert(temp[0].length == 3);
        assert(temp[1].length == 4);
        assert(temp[1][0].value == 4);
        assert(temp[1][1].value == 5);
        assert(temp[1][2].value == 6);
        assert(temp[1][3].value == 7);

        return true;
    }

    fn test3() external -> (bool) {
        S[][] memory temp = new S[][](2);

        temp[0] = a[0];
        temp[1] = a[1];

        assert(temp.length == 2);
        assert(temp[0].length == 3);
        assert(temp[1].length == 4);
        assert(temp[1][0].value == 4);
        assert(temp[1][1].value == 5);
        assert(temp[1][2].value == 6);
        assert(temp[1][3].value == 7);

        return true;
    }

    fn test4() external -> (bool) {
        S[][] memory temp = new S[][](2);

        temp[0] = a[0];
        temp[1] = b;

        assert(temp.length == 2);
        assert(temp[0].length == 3);
        assert(temp[1].length == 4);
        assert(temp[1][0].value == 4);
        assert(temp[1][1].value == 5);
        assert(temp[1][2].value == 6);
        assert(temp[1][3].value == 7);

        return true;
    }
}
// ====
// EVMVersion: >homestead
// compileViaYul: also
// ----
// test1() -> true
// gas irOptimized: 150533
// gas legacy: 150266
// gas legacyOptimized: 149875
// test2() -> true
// test3() -> true
// test4() -> true
