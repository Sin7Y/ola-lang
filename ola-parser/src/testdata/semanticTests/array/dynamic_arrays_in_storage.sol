contract c {
    struct Data {
        u256 x;
        u256 y;
    }
    Data[] data;
    u256[] ids;

    fn setIDStatic(u256 id)  {
        ids[2] = id;
    }

    fn setID(u256 index, u256 id)  {
        ids[index] = id;
    }

    fn setData(u256 index, u256 x, u256 y)  {
        data[index].x = x;
        data[index].y = y;
    }

    fn getID(u256 index)  -> (u256) {
        return ids[index];
    }

    fn getData(u256 index)  -> (u256 x, u256 y) {
        x = data[index].x;
        y = data[index].y;
    }

    fn getLengths()  -> (u256 l1, u256 l2) {
        l1 = data.length;
        l2 = ids.length;
    }

    fn setLengths(u256 l1, u256 l2)  {
        while (data.length < l1) data.push();
        while (ids.length < l2) ids.push();
    }
}

// ====
// compileViaYul: also
// ----
// getLengths() -> 0, 0
// setLengths(u256,u256): 48, 49 ->
// gas irOptimized: 111295
// gas legacy: 108571
// gas legacyOptimized: 100417
// getLengths() -> 48, 49
// setIDStatic(u256): 11 ->
// getID(u256): 2 -> 11
// setID(u256,u256): 7, 8 ->
// getID(u256): 7 -> 8
// setData(u256,u256,u256): 7, 8, 9 ->
// setData(u256,u256,u256): 8, 10, 11 ->
// getData(u256): 7 -> 8, 9
// getData(u256): 8 -> 10, 11
