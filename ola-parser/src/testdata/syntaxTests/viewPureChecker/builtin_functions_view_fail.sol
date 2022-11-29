contract C {
    fn f() view  {
        payable(this).transfer(1);
    }
    fn g() view  {
        require(payable(this).send(2));
    }
    fn h() view  {
        selfdestruct(payable(this));
    }
    fn i() view  {
        (bool success,) = address(this).delegatecall("");
        require(success);
    }
    fn j() view  {
        (bool success,) = address(this).call("");
        require(success);
    }
    receive() payable external {
    }
}
// ----
// TypeError 8961: (52-77): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (132-153): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (201-228): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (293-323): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (414-436): fn cannot be declared as view because this expression (potentially) modifies the state.
