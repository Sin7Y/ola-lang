pragma abicoder v1;

type MyBytes2 is bytes2;

contract C {
    fn f(MyBytes2 val) external -> (bytes2 ret) {
        assembly {
            ret := val
        }
    }

    fn g(bytes2 val) external -> (bytes2 ret) {
        assembly {
            ret := val
        }
    }

    fn h(u256 val) external -> (MyBytes2) {
        MyBytes2 ret;
        assembly {
            ret := val
        }
        return ret;
    }

}
// ====
// compileViaYul: false
// ----
// f(bytes2): "ab" -> 0x6162000000000000000000000000000000000000000000000000000000000000
// g(bytes2): "ab" -> 0x6162000000000000000000000000000000000000000000000000000000000000
// f(bytes2): "abcdef" -> 0x6162000000000000000000000000000000000000000000000000000000000000
// g(bytes2): "abcdef" -> 0x6162000000000000000000000000000000000000000000000000000000000000
// h(u256): "ab" -> 0x6162000000000000000000000000000000000000000000000000000000000000
// h(u256): "abcdef" -> 0x6162000000000000000000000000000000000000000000000000000000000000
