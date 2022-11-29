pragma solidity >= 0.6.0;

contract C {
    fn d(uint n) external pure -> (uint[] memory) {
        uint[] memory data = new uint[](n);
        for (uint i = 0; i < data.length; ++i)
            data[i] = i;
        return data;
    }

    fn dt(uint n) public view -> (uint) {
        uint[] memory data = this.d(n);
        uint sum = 0;
        for (uint i = 0; i < data.length; ++i)
            sum += data[i];
        return sum;
    }
}

// ====
// EVMVersion: >=byzantium
// compileViaYul: also
// ----
// dt(u256): 4 -> 6
