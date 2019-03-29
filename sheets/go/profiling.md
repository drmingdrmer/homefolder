### install

```
go get -v github.com/uber/go-torch

git clone https://github.com/brendangregg/FlameGraph
cp flamegraph.pl /usr/local/bin
```

### profiling

```
# go test ./array -cpuprofile prof.cpu -benchmem -bench=BenchmarkU16Get -run=none

go test ./array -cpuprofile prof.cpu -bench=BenchmarkU16Get -run=none
go-torch -b prof.cpu -f prof.cpu.svg
```
