contract c {
    fn f4(mapping(uint => uint) storage) pure internal {}
    fn f5(mapping(uint => uint) memory) pure internal {}
}
// ----
// TypeError 4061: (93-121): Type mapping(uint256 => uint256) is only valid in storage because it contains a (nested) mapping.
