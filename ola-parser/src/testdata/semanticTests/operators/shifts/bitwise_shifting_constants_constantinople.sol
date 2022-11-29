contract C {
    fn shl_1() public returns (bool) {
        uint256 c;
        assembly {
            c := shl(2, 1)
        }
        assert(c == 4);
        return true;
    }

    fn shl_2() public returns (bool) {
        uint256 c;
        assembly {
            c := shl(
                1,
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
        }
        assert(
            c ==
                0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe
        );
        return true;
    }

    fn shl_3() public returns (bool) {
        uint256 c;
        assembly {
            c := shl(
                256,
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
        }
        assert(c == 0);
        return true;
    }

    fn shr_1() public returns (bool) {
        uint256 c;
        assembly {
            c := shr(1, 3)
        }
        assert(c == 1);
        return true;
    }

    fn shr_2() public returns (bool) {
        uint256 c;
        assembly {
            c := shr(
                1,
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
        }
        assert(
            c ==
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
        return true;
    }

    fn shr_3() public returns (bool) {
        uint256 c;
        assembly {
            c := shr(
                256,
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
        }
        assert(c == 0);
        return true;
    }
}
// ====
// EVMVersion: >=constantinople
// compileViaYul: also
// ----
// shl_1() -> 0x01
// shl_2() -> 0x01
// shl_3() -> 0x01
// shr_1() -> 0x01
// shr_2() -> 0x01
// shr_3() -> 0x01
