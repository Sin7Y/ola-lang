contract C
{
    fn f(u256 x)  payable {
        assembly {
            x := callvalue()
        }
    }
}
// ----
