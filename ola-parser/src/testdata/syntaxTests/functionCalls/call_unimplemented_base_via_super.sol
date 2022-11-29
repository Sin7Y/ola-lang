abstract contract I {
    fn a() internal view virtual returns(uint256);
}

abstract contract C is I {
    fn f() public view returns(uint256) {
        return I.a();
    }
}

abstract contract D is I {
    fn f() public view returns(uint256) {
        return super.a();
    }
}
// ----
// TypeError 7501: (172-177): Cannot call unimplemented base fn.
// TypeError 9582: (278-285): Member "a" not found or not visible after argument-dependent lookup in type(contract super D).
