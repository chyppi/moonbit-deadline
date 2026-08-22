# 本地验收基线

本文件只记录实际命令产生的结果。耗时数据与机器、操作系统和 MoonBit 工具链有关，不作为跨平台性能承诺。

## 统计口径

有效源码由 `scripts/audit.ps1` 统计：递归读取参与项目的 `.mbt` 文件，排除构建目录、缓存和生成接口文件。

## 当前基线

基线命令：

```text
moon version --all
pwsh -File scripts/audit.ps1
moon check --target all --deny-warn
moon test --target wasm-gc --deny-warn
```

当前本地 native 复核也已通过；完整命令结果记录在 `docs/acceptance-local-report.md`。耗时数据只代表本机运行，不作为跨平台性能承诺。
