Do not need to be in GOPATH

go mod init creates a new module, initializing the go.mod file that describes it.
go build, go test, and other package-building commands add new dependencies to go.mod as needed.
go list -m all prints the current module’s dependencies.
go get changes the required version of a dependency (or adds a new dependency).
go mod tidy removes unused dependencies.

### init module

go mod init example.com/hello


### list modules

go list -m all


### list mod versions

go list -m -versions rsc.io/sampler

> rsc.io/sampler v1.0.0 v1.2.0 v1.2.1 v1.3.0 v1.3.1 v1.99.99


### upgrade

go get rsc.io/sampler

go get rsc.io/sampler@v1.3.1


### query

go list -m rsc.io/q...


### clean

go mod tidy


### add dependency to `./vendor`

go mod vendor

https://blog.golang.org/using-go-modules
