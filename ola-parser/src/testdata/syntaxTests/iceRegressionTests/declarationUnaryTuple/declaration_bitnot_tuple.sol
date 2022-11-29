contract C
{
    fn f() 
    {
        int x = ~(0,);
    }
}
// ----
// TypeError 8381: (60-64): Tuple component cannot be empty.
