contract C
{
    fn f(u256 x)  {
        assembly {
            x := callvalue()
        }
    }
}
// ----
// Warning 2018: (17-108): fn state mutability can be restricted to view
