abstract contract AbstractContract {
    constructor() { }
    fn utterance()  -> (bytes32) { return "miaow"; }
}

contract Test {
    fn create()  {
       AbstractContract ac = new AbstractContract();
    }
}
// ----
// TypeError 4614: (208-228): Cannot instantiate an abstract contract.
