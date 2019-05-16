XPTemplate priority=sub

let s:f = g:XPTfuncs()

" use snippet 'varConst' to generate contant variables
" use snippet 'varFormat' to generate formatting variables
" use snippet 'varSpaces' to generate spacing variables


XPTinclude
      \ _common/common


XPT ut " func TestXXX
func Test`f^(t *testing.T) {

    ta := require.New(t)

    cases := []struct {
        input int
        want  int
    }{
    }

    for i, c := range cases {
        got := `f^(c.input)
        ta.Equal(c.want, got,
            "%d-th: input: %#v; want: %#v; got: %#v",
            i+1, c.input, c.want, got)
    }
}

XPT ben " func BenchmarkXXX
func Benchmark`f^(b *testing.B) {
    for i = 0; i < b.N; i++ {
        `f^()
    }
}

XPT noerr " if err != nil { t.Fatalf... }
ta.Nil(err, "`i^EchoIfNoChange("%d-th: ")^^want no error but: %+v", ``i`+1, ^`err^)

XPT nonil " if err != nil { t.Fatalf... }
ta.NotNil(`v^, "`i^EchoIfNoChange("%d-th: ")^^want not nil", ``i`+1^)

XPT fail " ta.Fail...
ta.Fail("`i^EchoIfNoChange("%d-th: ")^^``msg` ^%+v", ``i`+1, ^`want^)

XPT equal " ta.Equal...
ta.Equal(`want^, `got^, "`i^EchoIfNoChange("%d-th: ")^^``msg` ^input: %+v", ``i`+1, ^`inp^)

XPT msg " msg := fmt.Sprintf...
msg := fmt.Sprintf("`i^EchoIfNoChange("%d-th: ")^^``msg` ^input: %+v", ``i`+1, ^`inp^)

XPT fatal " t.Fatalf...
t.Fatalf("``msg` ^want: %v; but: %v", `want^, `got^)
