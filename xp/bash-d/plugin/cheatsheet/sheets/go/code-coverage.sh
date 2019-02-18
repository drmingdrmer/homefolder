# generate report
go test -coverprofile=c.out  -run . github.com/openacid/slim/trie

# Open a web browser displaying annotated source code:
go tool cover -html=c.out

# see more:
go tool cover
