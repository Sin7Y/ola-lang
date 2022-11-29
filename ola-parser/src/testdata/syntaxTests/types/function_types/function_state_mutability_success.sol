contract Test
{
  uint y;
  fn internalPureFunc(uint256 x) internal pure returns (uint256) { return x; }
  fn internalViewFunc(uint256 x) internal view returns (uint256) { return x + y; }
  fn internalMutableFunc(uint256 x) internal returns (uint256) { y = x; return x; }

  fn externalPureFunc(uint256 x) external pure returns (uint256) { return x; }
  fn externalViewFunc(uint256 x) external view returns (uint256) { return x + y; }
  fn externalPayableFunc(uint256 x) external payable returns (uint256) { return x + y; }
  fn externalMutableFunc(uint256 x) external returns (uint256) { y = x; return x; }

  fn funcTakesInternalPure(fn(uint256) internal pure returns(uint256) a) internal pure returns (uint256) { return a(4); }
  fn funcTakesInternalView(fn(uint256) internal view returns(uint256) a) internal view returns (uint256) { return a(4); }
  fn funcTakesInternalMutable(fn(uint256) internal returns(uint256) a) internal returns (uint256) { return a(4); }

  fn funcTakesExternalPure(fn(uint256) external pure returns(uint256) a) internal pure returns (uint256) { return a(4); }
  fn funcTakesExternalView(fn(uint256) external view returns(uint256) a) internal view returns (uint256) { return a(4); }
  fn funcTakesExternalPayable(fn(uint256) external payable returns(uint256) a) internal returns (uint256) { return a(4); }
  fn funcTakesExternalMutable(fn(uint256) external returns(uint256) a) internal returns (uint256) { return a(4); }

  fn tests() internal
  {
    funcTakesInternalPure(internalPureFunc);

    funcTakesInternalView(internalPureFunc);
    funcTakesInternalView(internalViewFunc);

    funcTakesInternalMutable(internalPureFunc);
    funcTakesInternalMutable(internalViewFunc);
    funcTakesInternalMutable(internalMutableFunc);

    funcTakesExternalPure(this.externalPureFunc);

    funcTakesExternalView(this.externalPureFunc);
    funcTakesExternalView(this.externalViewFunc);

    funcTakesExternalPayable(this.externalPayableFunc);

    funcTakesExternalMutable(this.externalPureFunc);
    funcTakesExternalMutable(this.externalViewFunc);
    funcTakesExternalMutable(this.externalPayableFunc);
    funcTakesExternalMutable(this.externalMutableFunc);
  }
}
// ----
