// This used to crash with some compiler versions.
contract SomeContract {

  uint public balance = 0;

  fn balance(uint number) public {}

  fn doSomething() public {
    balance(3);
  }
}
// ----
// DeclarationError 2333: (106-145): Identifier already declared.
// TypeError 5704: (185-195): Type is not callable
