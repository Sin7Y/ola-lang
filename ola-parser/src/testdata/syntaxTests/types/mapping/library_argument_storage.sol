library Set {
    struct Data { mapping(uint => bool) flags; }

    fn insert(Data storage self, uint value)
        public
        returns (bool)
    {
        if (self.flags[value])
            return false; // already there
        self.flags[value] = true;
        return true;
    }
}
// ----
