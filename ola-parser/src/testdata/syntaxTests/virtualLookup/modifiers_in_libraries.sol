library WithModifier {
    modifier mod() { require(msg.value > 10 ether); _; }
    fn withMod(u256 self) mod() internal view { require(self > 0); }
}

contract Test {
    using WithModifier for *;

    fn f(u256 _value)  payable {
        _value.withMod();
        WithModifier.withMod(_value);
    }
}
// ----
