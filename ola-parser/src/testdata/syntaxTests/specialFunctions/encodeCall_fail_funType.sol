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
	fn baseFunctionInternal(uint) internal pure {}
	fn baseFunctionPublic(uint) public pure {}
}

fn fileLevel(uint) pure {}

contract C is Base {
	using L for uint256;

	fn fPublic(int a) public {}
	fn fInternal(uint256 p, string memory t) internal {}

	fn failFunctionPtrMissing() public returns(bytes memory) {
		return abi.encodeCall(1, this.fPublic);
	}
	fn failFunctionPtrWrongType() public returns(bytes memory) {
		return abi.encodeCall(abi.encodeCall, (1, 2, 3, "test"));
	}
	fn failFunctionInternal() public returns(bytes memory) {
		return abi.encodeCall(fInternal, (1, "123"));
	}
	fn failFunctionInternalFromVariable() public returns(bytes memory) {
		fn(uint256, string memory) internal localFunctionPointer = fInternal;
		return abi.encodeCall(localFunctionPointer, (1, "123"));
	}
	fn failLibraryPointerCall() public {
		abi.encodeCall(L.fInternal, (1, "123"));
		abi.encodeCall(L.fExternal, (1, "123"));
	}
	fn failBoundLibraryPointerCall() public returns (bytes memory) {
		uint256 x = 1;
		return abi.encodeCall(x.fExternal, (1, "123"));
	}
	fn viaBaseDeclaration() public pure returns (bytes memory) {
		return abi.encodeCall(C.fPublic, (2));
	}
	fn viaBaseDeclaration2() public pure returns (bytes memory) {
		return bytes.concat(
			abi.encodeCall(Base.baseFunctionPublic, (1)),
			abi.encodeCall(Base.baseFunctionInternal, (1))
		);
	}
	fn fileLevelFunction() public pure returns (bytes memory) {
		return abi.encodeCall(fileLevel, (2));
	}
	fn createFunction() public pure returns (bytes memory) {
		return abi.encodeCall(new Other, (2));
	}
}
// ----
// TypeError 5511: (742-743): Expected first argument to be a fn pointer, not "int_const 1".
// TypeError 3509: (855-869): Expected regular external fn type, or external view on public fn. Cannot use special fn.
// TypeError 3509: (982-991): Expected regular external fn type, or external view on public fn. Provided internal fn.
// TypeError 3509: (1187-1207): Expected regular external fn type, or external view on public fn. Provided internal fn.
// TypeError 3509: (1286-1297): Expected regular external fn type, or external view on public fn. Provided internal fn.
// TypeError 3509: (1329-1340): Expected regular external fn type, or external view on public fn. Cannot use library functions for abi.encodeCall.
// TypeError 3509: (1471-1482): Expected regular external fn type, or external view on public fn. Cannot use library functions for abi.encodeCall.
// TypeError 3509: (1592-1601): Expected regular external fn type, or external view on public fn. Provided internal fn. Did you forget to prefix "this."?
// TypeError 3509: (1722-1745): Expected regular external fn type, or external view on public fn. Provided internal fn. Functions from base contracts have to be external.
// TypeError 3509: (1771-1796): Expected regular external fn type, or external view on public fn. Provided internal fn. Functions from base contracts have to be external.
// TypeError 3509: (1902-1911): Expected regular external fn type, or external view on public fn. Provided internal fn.
// TypeError 3509: (2010-2019): Expected regular external fn type, or external view on public fn. Provided creation fn.
