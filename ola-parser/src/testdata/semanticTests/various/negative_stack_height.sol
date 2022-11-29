contract C {
    mapping(u256 => Invoice)  invoices;
    struct Invoice {
        u256 AID;
        bool Aboola;
        bool Aboolc;
        bool exists;
    }

    fn nredit(u256 startindex)
        
        pure
        -> (
            u256[500] memory CIDs,
            u256[500] memory dates,
            u256[500] memory RIDs,
            bool[500] memory Cboolas,
            u256[500] memory amounts
        )
    {}

    fn return500InvoicesByDates(
        u256 begindate,
        u256 enddate,
        u256 startindex
    )
        
        view
        -> (
            u256[500] memory AIDs,
            bool[500] memory Aboolas,
            u256[500] memory dates,
            bytes32[3][500] memory Abytesas,
            bytes32[3][500] memory bytesbs,
            bytes32[2][500] memory bytescs,
            u256[500] memory amounts,
            bool[500] memory Aboolbs,
            bool[500] memory Aboolcs
        )
    {}

    fn return500PaymentsByDates(
        u256 begindate,
        u256 enddate,
        u256 startindex
    )
        
        view
        -> (
            u256[500] memory BIDs,
            u256[500] memory dates,
            u256[500] memory RIDs,
            bool[500] memory Bboolas,
            bytes32[3][500] memory bytesbs,
            bytes32[2][500] memory bytescs,
            u256[500] memory amounts,
            bool[500] memory Bboolbs
        )
    {}
}

// via yul disabled because of stack issues.

// ====
// compileViaYul: false
// ----
// constructor() ->
// gas legacy: 588138
// gas legacyOptimized: 349636
