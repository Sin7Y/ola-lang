contract test {
	u256 value1;
	u256 value2;
	fn f(u256 x, u256 y)  -> (u256 w) {
		u256 value3 = y;
		value1 += x;
		value3 *= x;
		value2 *= value3 + value1;
		return value2 += 7;
	}
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256,u256): 0, 6 -> 7
// f(u256,u256): 1, 3 -> 0x23
// f(u256,u256): 2, 25 -> 0x0746
// f(u256,u256): 3, 69 -> 396613
// f(u256,u256): 4, 84 -> 137228105
// f(u256,u256): 5, 2 -> 0xcc7c5e28
// f(u256,u256): 6, 51 -> 1121839760671
// f(u256,u256): 7, 48 -> 408349672884251
