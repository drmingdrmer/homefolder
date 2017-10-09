
| feature               | yappi | pyinstrument |
| :--                   | :--   | :--          |
| Multithread-profiling | yes   | no           |

---

python -m cProfile -s cumtime lwn2pocket.py

python -m cProfile -s cumtime lwn2pocket.py
python -m cProfile -o prof.out mycode.py

pip install pyprof2calltree
pip install pycallgraph


pip install gprof2dot
python -m cProfile -o prof.out mycode.py
gprof2dot -f pstats prof.out -o callingGraph.dot


# yappi


```
# pip install yappi
# pip install gprof2dot
# brew install graphviz # required by gprof2dot to generate `.dot`

yappi -o yp.out ben.py
gprof2dot -f pstats yp.out | dot -Tpng -o yp.png
```

# pyinstrument


```
pip install pyinstrument
python -m pyinstrument              --color -o ~/pp.out mycode.py
```

---

```
--setprofile          run in setprofile mode, instead of signal mode
python -m pyinstrument --setprofile --color -o ~/pp.out mycode.py
```

```
4.365 <module>  manager.py:4
├─ 3.327 cmdloop  manager.py:66
│  └─ 3.327 cmdloop  cmd.py:102
├─ 0.730 __init__  manager.py:40
│  └─ 0.730 load_external_cmd  manager.py:48
│     └─ 0.730 submodules  modutil.py:7
│        └─ 0.727 load_module  pkgutil.py:243
│           ├─ 0.509 <module>  mgrcmds/cmd_node.py:4
│           │  └─ 0.487 load_autoinst_tags  autoinst.py:52
│           │     └─ 0.487 make_zk  s2zk.py:198
│           │        └─ 0.487 make_zk  zkclient.py:221
│           │           └─ 0.487 __init__  zkclient.py:57
│           │              └─ 0.487 connect  zkclient.py:68
│           │                 └─ 0.487 _connect  zkclient.py:72
│           │                    └─ 0.484 wait  threading.py:308
│           └─ 0.069 <module>  mgrcmds/cmd_core2cli.py:4
│              └─ 0.068 get_subcmd  mgrcmds/cmd_core2cli.py:295
└─ 0.296 <module>  cmdutil.py:4
   ├─ 0.219 <module>  autoinst.py:4
   │  ├─ 0.075 <module>  clusterinforeader.py:4
   │  │  └─ 0.068 <module>  statskey.py:5
   │  │     └─ 0.068 <module>  conf.py:1
   │  └─ 0.044 <module>  s2zk.py:4
   └─ 0.076 load_autoinst_tags  autoinst.py:52
      └─ 0.076 make_zk  s2zk.py:198
         └─ 0.075 make_zk  zkclient.py:221
            └─ 0.075 __init__  zkclient.py:57
               └─ 0.075 connect  zkclient.py:68
                  └─ 0.075 _connect  zkclient.py:72
                     └─ 0.075 wait  threading.py:308
```
