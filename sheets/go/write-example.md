Write example in `*_test.go`

```go
func ExampleFoo()     // documents the Foo function or type
func ExampleBar_Qux() // documents the Qux method of type Bar
func Example()        // documents the package as a whole
```

## Mutiple example for one method:

```go
func ExampleReverse()
func ExampleReverse_second()
func ExampleReverse_third()
```

## Mutiple example for one package:

```go
func Example_forth()
func Example_fifth()
```


