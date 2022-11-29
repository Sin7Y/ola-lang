contract BinarySearch {
    /// Finds the position of _value in the sorted list _data.
    /// Note that "internal" is important here, because storage references only work for internal or private functions
    fn find(u256[] storage _data, u256 _value)
        internal
        -> (u256 o_position)
    {
        return find(_data, 0, _data.length, _value);
    }

    fn find(
        u256[] storage _data,
        u256 _begin,
        u256 _len,
        u256 _value
    ) private -> (u256 o_position) {
        if (_len == 0 || (_len == 1 && _data[_begin] != _value))
            return type(u256).max; // failure
        u256 halfLen = _len / 2;
        u256 v = _data[_begin + halfLen];
        if (_value < v) return find(_data, _begin, halfLen, _value);
        else if (_value > v)
            return find(_data, _begin + halfLen + 1, halfLen - 1, _value);
        else return _begin + halfLen;
    }
}


contract Store is BinarySearch {
    u256[] data;

    fn add(u256 v)  {
        data.push(0);
        data[data.length - 1] = v;
    }

    fn find(u256 v)  -> (u256) {
        return find(data, v);
    }
}

// ====
// compileViaYul: also
// ----
// find(u256): 7 -> -1
// add(u256): 7 ->
// find(u256): 7 -> 0
// add(u256): 11 ->
// add(u256): 17 ->
// add(u256): 27 ->
// add(u256): 31 ->
// add(u256): 32 ->
// add(u256): 66 ->
// add(u256): 177 ->
// find(u256): 7 -> 0
// find(u256): 27 -> 3
// find(u256): 32 -> 5
// find(u256): 176 -> -1
// find(u256): 0 -> -1
// find(u256): 400 -> -1
