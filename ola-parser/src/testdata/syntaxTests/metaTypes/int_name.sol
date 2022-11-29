contract test {
	fn intName()  {
		type(int).name;
	}
}
// ----
// TypeError 9582: (47-61): Member "name" not found or not visible after argument-dependent lookup in type(int256).
