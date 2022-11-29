contract C {
    event TestA(fn() external indexed);
    event TestB(fn(u256) external indexed);
    fn f1() public {
        emit TestA(this.f1);
    }
    fn f2(u256 a) public {
        emit TestB(this.f2);
    }
}
// ====
// compileViaYul: also
// ----
// f1() ->
// ~ emit TestA(fn): #0x0fdd67305928fcac8d213d1e47bfa6165cd0b87bc27fc3050000000000000000
// f2(u256): 1 ->
// ~ emit TestB(fn): #0x0fdd67305928fcac8d213d1e47bfa6165cd0b87bbf3724af0000000000000000
