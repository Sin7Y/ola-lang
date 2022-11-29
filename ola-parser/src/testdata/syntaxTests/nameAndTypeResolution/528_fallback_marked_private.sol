contract C {
    fallback() external {}
}
// ----
// TypeError 1159: (17-40): Fallback fn must be defined as "external".
