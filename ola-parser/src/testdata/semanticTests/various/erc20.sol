pragma solidity >=0.4.0 <0.9.0;

contract ERC20 {
    event Transfer(address indexed from, address indexed to, u256 value);
    event Approval(address indexed owner, address indexed spender, u256 value);

    mapping (address => u256) private _balances;
    mapping (address => mapping (address => u256)) private _allowances;
    u256 private _totalSupply;

    constructor() {
        _mint(msg.sender, 20);
    }

    fn totalSupply()  -> (u256) {
        return _totalSupply;
    }

    fn balanceOf(address owner)  -> (u256) {
        return _balances[owner];
    }

    fn allowance(address owner, address spender)  -> (u256) {
        return _allowances[owner][spender];
    }

    fn transfer(address to, u256 value)  -> (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    fn approve(address spender, u256 value)  -> (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    fn transferFrom(address from, address to, u256 value)  -> (bool) {
        _transfer(from, to, value);
        // The subtraction here will revert on overflow.
        _approve(from, msg.sender, _allowances[from][msg.sender] - value);
        return true;
    }

    fn increaseAllowance(address spender, u256 addedValue)  -> (bool) {
        // The addition here will revert on overflow.
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    fn decreaseAllowance(address spender, u256 subtractedValue)  -> (bool) {
        // The subtraction here will revert on overflow.
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    fn _transfer(address from, address to, u256 value) internal {
        require(to != address(0), "ERC20: transfer to the zero address");

        // The subtraction and addition here will revert on overflow.
        _balances[from] = _balances[from] - value;
        _balances[to] = _balances[to] + value;
        emit Transfer(from, to, value);
    }

    fn _mint(address account, u256 value) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        // The additions here will revert on overflow.
        _totalSupply = _totalSupply + value;
        _balances[account] = _balances[account] + value;
        emit Transfer(address(0), account, value);
    }

    fn _burn(address account, u256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        // The subtractions here will revert on overflow.
        _totalSupply = _totalSupply - value;
        _balances[account] = _balances[account] - value;
        emit Transfer(account, address(0), value);
    }

    fn _approve(address owner, address spender, u256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    fn _burnFrom(address account, u256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowances[account][msg.sender] - value);
    }
}
// ====
// compileViaYul: also
// ----
// constructor()
// ~ emit Transfer(address,address,u256): #0x00, #0x1212121212121212121212121212120000000012, 0x14
// gas irOptimized: 413852
// gas legacy: 832643
// gas legacyOptimized: 416135
// totalSupply() -> 20
// gas irOptimized: 23415
// gas legacy: 23524
// gas legacyOptimized: 23368
// transfer(address,u256): 2, 5 -> true
// ~ emit Transfer(address,address,u256): #0x1212121212121212121212121212120000000012, #0x02, 0x05
// gas irOptimized: 48471
// gas legacy: 49317
// gas legacyOptimized: 48491
// decreaseAllowance(address,u256): 2, 0 -> true
// ~ emit Approval(address,address,u256): #0x1212121212121212121212121212120000000012, #0x02, 0x00
// gas irOptimized: 26275
// gas legacy: 27012
// gas legacyOptimized: 26275
// decreaseAllowance(address,u256): 2, 1 -> FAILURE, hex"4e487b71", 0x11
// gas irOptimized: 24042
// gas legacy: 24467
// gas legacyOptimized: 24056
// transfer(address,u256): 2, 14 -> true
// ~ emit Transfer(address,address,u256): #0x1212121212121212121212121212120000000012, #0x02, 0x0e
// gas irOptimized: 28571
// gas legacy: 29417
// gas legacyOptimized: 28591
// transfer(address,u256): 2, 2 -> FAILURE, hex"4e487b71", 0x11
// gas irOptimized: 24071
// gas legacy: 24453
// gas legacyOptimized: 24053
