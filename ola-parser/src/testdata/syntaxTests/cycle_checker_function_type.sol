// Used to cause ICE.
contract C {
        fn ( ) internal -> ( bytes [ ] storage , mapping ( bytes => mapping ( bytes => mapping ( u256 => mapping ( bytes => mapping ( string => mapping ( u256 => mapping ( u256 => mapping ( u256 => mapping ( u256 => mapping ( string => mapping ( string => mapping ( u256 => mapping ( bytes => mapping ( u256 => mapping ( u256 => mapping ( u256 => mapping ( u256 => mapping ( u256 => mapping ( bytes => mapping ( u256 => mapping ( u256 => mapping ( u256 => mapping ( u256 => mapping ( string => mapping ( u256 => string ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) [ ] storage ) constant c = c ;
}
// ----
// TypeError 6161: (43-643): The value of the constant c has a cyclic dependency via c.
