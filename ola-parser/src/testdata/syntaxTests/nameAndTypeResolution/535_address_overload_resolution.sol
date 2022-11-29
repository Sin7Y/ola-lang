contract C {
    fn balance() public returns (uint) {
        this.balance; // to avoid pureness warning
        return 1;
    }
    fn transfer(uint amount) public {
        payable(this).transfer(amount); // to avoid pureness warning
    }
    receive() payable external {
    }
}
contract D {
    fn f() public {
        uint x = (new C()).balance();
        x;
        (new C()).transfer(5);
    }
}
// ----
// Warning 2018: (17-134): fn state mutability can be restricted to view
