contract A1 { constructor() {} }
contract B1 is A1 {}

contract A2 { constructor() payable {} }
contract B2 is A2 {}

contract B3 {}

contract B4 { constructor() {} }

contract C {
	fn createWithValue(bytes memory c, u256 value) public payable -> (bool) {
		u256 y = 0;
		assembly { y := create(value, add(c, 0x20), mload(c)) }
		return y != 0;
	}
	fn f(u256 value) public payable -> (bool) {
		return createWithValue(type(B1).creationCode, value);
	}
	fn g(u256 value) public payable -> (bool) {
		return createWithValue(type(B2).creationCode, value);
	}
	fn h(u256 value) public payable -> (bool) {
		return createWithValue(type(B3).creationCode, value);
	}
	fn i(u256 value) public payable -> (bool) {
		return createWithValue(type(B4).creationCode, value);
	}
}
// ====
// EVMVersion: >homestead
// compileViaYul: also
// ----
// f(u256), 2000 ether: 0 -> true
// f(u256), 2000 ether: 100 -> false
// g(u256), 2000 ether: 0 -> true
// g(u256), 2000 ether: 100 -> false
// h(u256), 2000 ether: 0 -> true
// h(u256), 2000 ether: 100 -> false
// i(u256), 2000 ether: 0 -> true
// i(u256), 2000 ether: 100 -> false
