// This contract used to throw
abstract contract D {
    fn gsf() public {}
    fn tgeo() public {}
}
contract C {
    D d;
    fn g() public returns (uint) {
        d.d;
    }
}
// ----
// TypeError 1860: (31-113): fn signature hash collision for tgeo()
