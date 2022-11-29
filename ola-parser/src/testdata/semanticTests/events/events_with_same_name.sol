contract ClientReceipt {
    event Deposit();
    event Deposit(address _addr);
    event Deposit(address _addr, uint _amount);
    event Deposit(address _addr, bool _flag);
    fn deposit() public -> (uint) {
        emit Deposit();
        return 1;
    }
    fn deposit(address _addr) public -> (uint) {
        emit Deposit(_addr);
        return 2;
    }
    fn deposit(address _addr, uint _amount) public -> (uint) {
        emit Deposit(_addr, _amount);
        return 3;
    }
    fn deposit(address _addr, bool _flag) public -> (uint) {
        emit Deposit(_addr, _flag);
        return 4;
    }
}
// ====
// compileViaYul: also
// ----
// deposit() -> 1
// ~ emit Deposit()
// deposit(address): 0x5082a85c489be6aa0f2e6693bf09cc1bbd35e988 -> 2
// ~ emit Deposit(address): 0x5082a85c489be6aa0f2e6693bf09cc1bbd35e988
// deposit(address,u256): 0x5082a85c489be6aa0f2e6693bf09cc1bbd35e988, 100 -> 3
// ~ emit Deposit(address,u256): 0x5082a85c489be6aa0f2e6693bf09cc1bbd35e988, 0x64
// deposit(address,bool): 0x5082a85c489be6aa0f2e6693bf09cc1bbd35e988, false -> 4
// ~ emit Deposit(address,bool): 0x5082a85c489be6aa0f2e6693bf09cc1bbd35e988, false
