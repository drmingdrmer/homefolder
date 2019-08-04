
# install deps
# cd github/openacid/low
go install ./...

# go tool compile does not read GOPATH, need to specify it manually with "-I"
# Use multiple -I for more then one GOPATH.
go tool compile -I $GOPATH/pkg/darwin_amd64 -S x.go

