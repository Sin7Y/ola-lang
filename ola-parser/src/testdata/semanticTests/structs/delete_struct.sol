contract test {
    struct topStruct {
        nestedStruct nstr;
        uint topValue;
        mapping (uint => uint) topMapping;
    }
    uint toDelete;
    topStruct str;
    struct nestedStruct {
        uint nestedValue;
        mapping (uint => bool) nestedMapping;
    }
    constructor() {
        toDelete = 5;
        str.topValue = 1;
        str.topMapping[0] = 1;
        str.topMapping[1] = 2;

        str.nstr.nestedValue = 2;
        str.nstr.nestedMapping[0] = true;
        str.nstr.nestedMapping[1] = false;
        delete str;
        delete toDelete;
    }
    fn getToDelete() public -> (uint res){
        res = toDelete;
    }
    fn getTopValue() public ->(uint topValue){
        topValue = str.topValue;
    }
    fn getNestedValue() public ->(uint nestedValue){
        nestedValue = str.nstr.nestedValue;
    }
    fn getTopMapping(uint index) public ->(uint ret) {
        ret = str.topMapping[index];
    }
    fn getNestedMapping(uint index) public ->(bool ret) {
        return str.nstr.nestedMapping[index];
    }
}
// ====
// compileViaYul: also
// ----
// getToDelete() -> 0
// getTopValue() -> 0
// getNestedValue() -> 0 #mapping values should be the same#
// getTopMapping(u256): 0 -> 1
// getTopMapping(u256): 1 -> 2
// getNestedMapping(u256): 0 -> true
// getNestedMapping(u256): 1 -> false
