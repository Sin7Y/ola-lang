contract Test {
        struct RecursiveStruct {
                address payable d ;
                mapping ( u256 => address payable ) c ;
                mapping ( u256 => address payable [ ] ) d ;
        }
        fn func ( ) private pure {
                RecursiveStruct [ 1 ] memory val ;
                val ;
        }
}
// ----
// DeclarationError 2333: (157-198): Identifier already declared.
// TypeError 4061: (268-300): Type struct Test.RecursiveStruct[1] is only valid in storage because it contains a (nested) mapping.
