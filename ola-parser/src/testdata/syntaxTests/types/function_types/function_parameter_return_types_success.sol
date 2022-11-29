contract Test
{
  fn uint256_to_uint256(uint256 x) internal pure returns (uint256) { return x; }
  fn uint256_to_string(uint256 x) internal pure returns (string memory) { return x == 0 ? "a" : "b"; }
  fn string_to_uint256(string memory x) internal pure returns (uint256) { return bytes(x).length; }
  fn string_to_string(string memory x) internal pure returns (string memory) { return x; }

  fn uint256_uint256_to_uint256(uint256 x, uint256 y) internal pure returns (uint256) { return x + y; }
  fn uint256_uint256_to_string(uint256 x, uint256 y) internal pure returns (string memory) { return x == y ? "a" : "b"; }
  fn string_uint256_to_string(string memory x, uint256 y) internal pure returns (string memory) { return y == 0 ? "a" : x; }
  fn string_string_to_string(string memory x, string memory y) internal pure returns (string memory) { return bytes(x).length == 0 ? y : x; }
  fn uint256_string_to_string(uint256 x, string memory y) internal pure returns (string memory) { return x == 0 ? "a" : y; }

  fn tests() internal pure
  {
    fn (uint256) internal pure returns (uint256) var_uint256_to_uint256 = uint256_to_uint256;
    fn (uint256) internal pure returns (string memory) var_uint256_to_string = uint256_to_string;
    fn (string memory) internal pure returns (uint256) var_string_to_uint256 = string_to_uint256;
    fn (string memory) internal pure returns (string memory) var_string_to_string = string_to_string;

    fn (uint256, uint256) internal pure returns (uint256) var_uint256_uint256_to_uint256 = uint256_uint256_to_uint256;
    fn (uint256, uint256) internal pure returns (string memory) var_uint256_uint256_to_string = uint256_uint256_to_string;
    fn (string memory, uint256) internal pure returns (string memory) var_string_uint256_to_string = string_uint256_to_string;
    fn (string memory, string memory) internal pure returns (string memory) var_string_string_to_string = string_string_to_string;
    fn (uint256, string memory) internal pure returns (string memory) var_uint256_string_to_string = uint256_string_to_string;

    // Avoid unused variable warnings:
    var_uint256_to_uint256(1);
    var_uint256_to_string(2);
    var_string_to_uint256("a");
    var_string_to_string("b");
    var_uint256_uint256_to_uint256(3, 4);
    var_uint256_uint256_to_string(5, 6);
    var_string_uint256_to_string("c", 7);
    var_string_string_to_string("d", "e");
    var_uint256_string_to_string(8, "f");
  }
}
// ----
