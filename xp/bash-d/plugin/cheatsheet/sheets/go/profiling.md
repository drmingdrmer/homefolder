### install

```
go get -v github.com/uber/go-torch

git clone https://github.com/brendangregg/FlameGraph
cp flamegraph.pl /usr/local/bin
```

### profiling cpu and memory

- make profiling data of cpu and memory
```
go test ./array -cpuprofile prof.cpu -memprofile prof.mem -bench=BenchmarkU16Get -run=none
```

- make svg

```
# graph:
go tool pprof  -svg prof.cpu

# flame:
go-torch -b prof.cpu -f prof.cpu.svg
go-torch -b prof.mem -f prof.mem.svg
```

- command line analysis

```
go tool pprof prof.cpu


(pprof) top4
Showing nodes accounting for 1100ms, 94.02% of 1170ms total
Showing top 4 nodes out of 45
      flat  flat%   sum%        cum   cum%
     560ms 47.86% 47.86%      690ms 58.97%  github.com/openacid/slim/array.(*ArrayBase).GetEltIndex
     390ms 33.33% 81.20%     1080ms 92.31%  github.com/openacid/slim/array_test.BenchmarkArrayBaseGetEltIndex_10kelts
     130ms 11.11% 92.31%      130ms 11.11%  github.com/openacid/slim/bits.OnesCount64Before
      20ms  1.71% 94.02%       20ms  1.71%  runtime.nanotime


(pprof) list GetEltIndex
Total: 1.17s
ROUTINE ======================== github.com/openacid/slim/array.(*ArrayBase).GetEltIndex in /Users/drdrxp/xp/vcs/gh/openacid/slim/array/arraybase.go
     560ms      690ms (flat, cum) 58.97% of Total
         .          .     68:}
         .          .     69:
         .          .     70:// GetEltIndex returns the position in a.Elts of element[idx] and a bool
         .          .     71:// indicating if found or not.
         .          .     72:// If "idx" absents it returns "0, false".
      40ms       40ms     73:func (a *ArrayBase) GetEltIndex(idx int32) (int32, bool) {
     110ms      110ms     74:   iBm := idx >> bmShift
         .          .     75:   iBit := idx & bmMask
         .          .     76:
```

https://golang.org/pkg/runtime/pprof/

https://juejin.im/entry/5ac9cf3a518825556534c76e
https://www.cnblogs.com/yjf512/archive/2012/12/27/2835331.html
