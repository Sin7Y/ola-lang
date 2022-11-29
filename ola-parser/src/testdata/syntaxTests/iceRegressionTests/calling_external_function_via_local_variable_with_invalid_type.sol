contract C {
    fn f()  {
        fn() external -> (fn() internal) getCallback;
        getCallback();
    }
}
// ----
// TypeError 2582: (76-96): Internal type cannot be used for external fn type.
