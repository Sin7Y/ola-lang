contract D {}

contract C {
    using D for uint256;
}
// ----
// TypeError 4357: (38-39): Library name expected. If you want to attach a fn, use '{...}'.
