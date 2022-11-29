contract test {

    fn viewAssignment()  {
        int min = type(int).min;
        min;
    }

    fn assignment()  {
        int max = type(int).max;
        max;
    }

}
// ----
// Warning 2018: (21-112): fn state mutability can be restricted to pure
// Warning 2018: (118-200): fn state mutability can be restricted to pure
