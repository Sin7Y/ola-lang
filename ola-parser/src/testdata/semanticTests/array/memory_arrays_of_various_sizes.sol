// Computes binomial coefficients the chinese way
contract C {
    fn f(u256 n, u256 k) public -> (u256) {
        u256[][] memory rows = new u256[][](n + 1);
        for (u256 i = 1; i <= n; i++) {
            rows[i] = new u256[](i);
            rows[i][0] = rows[i][rows[i].length - 1] = 1;
            for (u256 j = 1; j < i - 1; j++)
                rows[i][j] = rows[i - 1][j - 1] + rows[i - 1][j];
        }
        return rows[n][k - 1];
    }
}
// ====
// compileViaYul: also
// ----
// f(u256,u256): 3, 1 -> 1
// f(u256,u256): 9, 5 -> 70
