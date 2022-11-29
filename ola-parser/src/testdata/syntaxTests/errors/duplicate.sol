==== Source: A ====

error E();

==== Source: B ====

error E();

==== Source: C ====

import "A" as A;
import "B" as B;

contract Test {
    fn f()  {
        revert A.E();
    }
    fn g()  {
        revert B.E();
    }
}
// ----
