Do not need to be in GOPATH


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

https://blog.golang.org/using-go-modules
