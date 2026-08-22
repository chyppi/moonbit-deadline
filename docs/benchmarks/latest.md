# 本地 benchmark 结果

运行日期：2026-08-22 15:49:28 +08:00

工具链：

~~~text
moon 0.1.20260814 (a2de5b2 2026-08-14) ~\.moon\bin\moon.exe
moonc v0.10.8+8606a5800 (2026-08-14) ~\.moon\bin\moonc.exe
moonrun 0.1.20260814 (a2de5b2 2026-08-14) ~\.moon\bin\moonrun.exe

Feature flags enabled: rr_moon_mod,rr_moon_pkg
~~~

命令：moon run bench/deadline_bench -- --iterations 100

~~~text
case=calendar iterations=100 checksum=48818044
case=deadline iterations=100 checksum=73967272
case=batch iterations=100 checksum=73983800

~~~

外层命令耗时：341.55 ms

checksum 用于确认 workload 真实完成；耗时受机器、操作系统和工具链影响，不作为跨机器性能承诺。
