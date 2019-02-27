func TestPanic(t *testing.T) {
    defer func() {
        if r := recover(); r == nil {
            t.Errorf("The code did not panic")
        }
    }()

    // The following is the code under test
    OtherFunctionThatPanics()
}

// I generally find testing to be fairly weak. You may be interested in more
// powerful testing engines like
//		Ginkgo.
// Even if you don't want the full Ginkgo system, you can use just its matcher
// library,
//		Gomega,
// which can be used along with testing. Gomega includes matchers like:
//
// See: https://stackoverflow.com/questions/31595791/how-to-test-panics
