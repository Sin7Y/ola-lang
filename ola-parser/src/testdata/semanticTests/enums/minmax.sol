contract test {
	enum MinMax { A, B, C, D }

	fn min()  ->(u256) { return u256(type(MinMax).min); }
	fn max()  ->(u256) { return u256(type(MinMax).max); }
}

// ====
// compileViaYul: also
// ----
// min() -> 0
// max() -> 3
