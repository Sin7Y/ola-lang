contract C {
        struct X { bytes31 [ 3 ] x1 ;
                u256 x2 ;
        }
        struct S { u256 [ ] [ 0.425781 ether ] s1 ;
                u256 [ 2 ** 0xFF ] [ 2 ** 0x42 ] s2 ;
                X s3 ;
                u256 [ 9 hours ** 16 ] d ;
                string s ;
        }
        fn f ( )  { fn ( fn ( bytes9 , u256 ) external pure -> ( u256 ) , u256 ) external pure -> ( u256 ) [ 3 ] memory s2 ;
                S memory s ;
        }
}
// ----
// TypeError 1534: (474-484): Type too large for memory.
