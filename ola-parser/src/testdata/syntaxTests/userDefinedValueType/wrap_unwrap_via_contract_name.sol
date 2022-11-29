contract C { type T is u256; }
library L { type T is u256; }
interface I { type T is u256; }
contract D
{
    C.T x = C.T.wrap(u256(1));
    L.T y = L.T.wrap(u256(1));
    I.T z = I.T.wrap(u256(1));
}
