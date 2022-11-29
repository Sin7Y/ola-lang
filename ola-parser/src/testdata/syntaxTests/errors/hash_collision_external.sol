library L {
    error gsf();
}
contract test {
    error tgeo();
    fn f(bool a)  {
        if (a)
            revert L.gsf();
        else
            revert tgeo();
    }
}
// ----
// TypeError 4883: (57-61): Error signature hash collision for tgeo()
