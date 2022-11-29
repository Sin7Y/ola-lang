interface I {
	fn fExternal(uint256 p, string memory t) external;
}

contract Other {
	fn fExternal(uint) external pure {}
	fn fPublic(uint) public pure {}
	fn fInternal(uint) internal pure {}
}

library L {
	fn fExternal(uint256 p, string memory t) external {}
	fn fInternal(uint256 p, string memory t) internal {}
}

contract Base {
	fn baseFunctionExternal(uint) external pure {}
}

contract C is Base {
	fn f(int a) public {}
	fn f2(int a, string memory b) public {}
	fn f4() public {}

	fn successFunctionArgsIntLiteralTuple() public view returns(bytes memory) {
		return abi.encodeCall(this.f, (1));
	}
	fn successFunctionArgsIntLiteral() public view returns(bytes memory) {
		return abi.encodeCall(this.f, 1);
	}
	fn successFunctionArgsLiteralTuple() public view returns(bytes memory) {
		return abi.encodeCall(this.f2, (1, "test"));
	}
	fn successFunctionArgsEmptyTuple() public view returns(bytes memory) {
		return abi.encodeCall(this.f4, ());
	}
	fn viaDeclaration() public pure returns (bytes memory) {
		return bytes.concat(
			abi.encodeCall(Other.fExternal, (1)),
			abi.encodeCall(Other.fPublic, (1)),
			abi.encodeCall(I.fExternal, (1, "123"))
		);
	}
	fn viaBaseDeclaration() public pure returns (bytes memory) {
		return abi.encodeCall(Base.baseFunctionExternal, (1));
	}
}
// ----
