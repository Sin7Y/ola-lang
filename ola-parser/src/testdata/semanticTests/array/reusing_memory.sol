// Invoke some features that use memory and test that they do not interfere with each other.
contract Helper {
    u256 public flag;

    constructor(u256 x) {
        flag = x;
    }
}


contract Main {
    mapping(u256 => u256) map;

    fn f(u256 x) public -> (u256) {
        map[x] = x;
        return
            (new Helper(u256(keccak256(abi.encodePacked(this.g(map[x]))))))
                .flag();
    }

    fn g(u256 a) public -> (u256) {
        return map[a];
    }
}
// ====
// compileViaYul: also
// ----
// f(u256): 0x34 -> 0x46bddb1178e94d7f2892ff5f366840eb658911794f2c3a44c450aa2c505186c1
// gas irOptimized: 113198
// gas legacy: 126596
// gas legacyOptimized: 113823
