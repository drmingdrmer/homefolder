XPTemplate priority=sub

let s:f = g:XPTfuncs()

" use snippet 'varConst' to generate contant variables
" use snippet 'varFormat' to generate formatting variables
" use snippet 'varSpaces' to generate spacing variables


XPTinclude
      \ _common/common


XPT ut " func TestXXX
func Test`f^(t *testing.T) {

	cases := []struct {
		input int
		want  int
	}{
		{1, 1},
	}

	for i, c := range cases {
		rst := `f^(c.input)
		if rst != c.want {
			t.Fatalf("%d-th: input: %#v; want: %#v; actual: %#v",
			i+1, c.input, c.want, rst)
		}
	}
}


XPT noerr " if err != nil { t.Fatalf... }
if `err^ != nil {
    t.Fatalf("`i^EchoIfNoChange("%d-th: ")^^expected no error but: %+v", ``i`+1, ^`err^)
}
