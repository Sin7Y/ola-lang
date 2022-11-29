contract C {
    u256[] data;
    fn f(u256 x, u256[] calldata input)  -> (u256, u256) {
        data.push(x);
        (u256 a, u256[] calldata b) = fun(input, data);
        return (a, b[1]);

    }
}

fn fun(u256[] calldata _x, u256[] storage _y) view  -> (u256, u256[] calldata) {
	return (_y[0], _x);
}
// ====
// compileViaYul: also
// ----
// f(u256,u256[]): 7, 0x40, 3, 8, 9, 10 -> 7, 9
