go tool objdump -S bin
go tool objdump bin

# https://stackoverflow.com/questions/23789951/easy-to-read-golang-assembly-output


# with gopath:
#   go tool compile -I $GOPATH/pkg/darwin_amd64 -S x.go
go tool compile -S x.go
