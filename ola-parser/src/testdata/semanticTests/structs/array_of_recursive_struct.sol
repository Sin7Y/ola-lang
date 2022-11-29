contract Test {
    struct RecursiveStruct {
        RecursiveStruct[] vals;
    }

    fn func()  {
        RecursiveStruct[1] memory val = [ RecursiveStruct(new RecursiveStruct[](42)) ];
        assert(val[0].vals.length == 42);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// func() ->
