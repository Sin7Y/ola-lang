abstract contract A {
    fn f() public view mod {
        require(block.timestamp > 10);
    }
    modifier mod() virtual;
}
