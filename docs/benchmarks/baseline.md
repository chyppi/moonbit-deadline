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

Windows native 测试的完整结果在 `progress.md` 中记录；在工具链运行库错误归因完成前，不在这里声称全目标测试通过。
