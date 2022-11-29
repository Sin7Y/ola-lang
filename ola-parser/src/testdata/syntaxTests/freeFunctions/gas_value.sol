fn fun() {
    fun{gas: 1}();
    fun{value: 1}();
}
// ----
// TypeError 2193: (21-32): fn call options can only be set on external fn calls or contract creations.
