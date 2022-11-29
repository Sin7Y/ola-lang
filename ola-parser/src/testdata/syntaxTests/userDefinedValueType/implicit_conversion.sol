type MyInt is uint;
type MyAddress is address;
fn f() pure {
    MyInt a;
    MyInt b = a;
    MyAddress c;
    MyAddress d = c;
    b;
    d;
}

fn g(MyInt a) pure returns (MyInt) {
    return a;
}
