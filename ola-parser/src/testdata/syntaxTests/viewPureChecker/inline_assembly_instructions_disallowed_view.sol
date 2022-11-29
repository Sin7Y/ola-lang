contract C {
    fn f()  {
        assembly {
            sstore(0, 1)
            pop(create(0, 1, 2))
            pop(create2(0, 1, 2, 3))
            pop(call(0, 1, 2, 3, 4, 5, 6))
            pop(callcode(0, 1, 2, 3, 4, 5, 6))
            pop(delegatecall(0, 1, 2, 3, 4, 5))
            selfdestruct(0)
            log0(0, 1)
            log1(0, 1, 2)
            log2(0, 1, 2, 3)
            log3(0, 1, 2, 3, 4)
            log4(0, 1, 2, 3, 4, 5)

            // These two are disallowed too but the error suppresses other errors.
            //pop(msize())
            //pop(pc())
        }
    }
}
// ====
// EVMVersion: >=london
// ----
// Warning 5740: (336-468): Unreachable code.
// TypeError 8961: (75-87): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (104-119): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (137-156): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (174-199): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (217-246): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (264-294): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (308-323): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (336-346): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (359-372): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (385-401): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (414-433): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (446-468): fn cannot be declared as view because this expression (potentially) modifies the state.
