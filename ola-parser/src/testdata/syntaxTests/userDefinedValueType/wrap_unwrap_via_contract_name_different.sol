contract C { type T is u256; }
library L { type T is u256; }
contract D
{
    C.T x = L.T.wrap(u256(1));
}
// ----
// TypeError 7407: (86-103): Type L.T is not implicitly convertible to expected type C.T.
