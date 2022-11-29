contract C {
    fn getOne() public payable nonFree -> (u256 r) {
        return 1;
    }

    modifier nonFree {
        if (msg.value > 0) _;
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// getOne() -> 0
// getOne(), 1 wei -> 1
