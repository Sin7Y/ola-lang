// Previous versions of Solidity turned this
// into a parser error (they wrongly recognized
// these functions as state variables of
// fn type).
abstract contract C
{
    modifier only_owner() { _; }
    fn foo() only_owner  virtual;
    fn bar()  only_owner virtual;
}
// ----
// SyntaxError 2668: (212-253): Functions without implementation cannot have modifiers.
// SyntaxError 2668: (258-299): Functions without implementation cannot have modifiers.
