# moonbit-deadline 本地验收自查报告

生成日期：2026-08-22

本报告按八月黑客松口径整理，参考公开的 [`osc2026-guide`](https://github.com/Milky2018/osc2026-guide) 检查项和 [MoonBit 社区 workflow templates](https://github.com/moonbit-community/.github/tree/main/workflow-templates)。本轮已将验收提交推送到 GitHub `chyppi/moonbit-deadline` 的 `main`，验证三平台 CI 通过，并完成 Mooncakes `chyppi/moonbit-deadline@0.1.0` 发布。

## 总体判断

本地仓库已经具备可运行的 MoonBit 库、CLI、边界测试、benchmark、许可证和 CI 配置。有效 `.mbt` 源码规模已超过 8,000 行，核心可移植目标检查/测试/构建通过。

验收结果：

- Mooncakes `chyppi/moonbit-deadline@0.1.0` 已通过校验并发布；申报书和内部计划文件未进入发布归档。
- 验收提交已推送到 GitHub `main`；本报告提交后以远程最新提交和 Actions 结果为准。
- GitHub Actions 对 Ubuntu、macOS 和 Windows 均配置了检查；最新运行结果在项目的 Actions 页面核验。
- 本次清理 `_build` 后，Windows MinGW native 测试和构建均已通过；此前记录的 `rand_s` 错误在当前工具链状态下已不再复现。

## 已检查证据

### 工具链和规模

`moon version --all`：

```text
moon 0.1.20260814 (a2de5b2 2026-08-14)
moonc v0.10.8+8606a5800 (2026-08-14)
moonrun 0.1.20260814 (a2de5b2 2026-08-14)
```

`pwsh -File scripts/audit.ps1`：

```text
files=110 lines=9999 tests=272
```

统计排除了 `pkg.generated.mbti`、`_build`、`.moon`、`target` 和 `node_modules`；行数来自实际 `.mbt` 文件读取，不是 README 声明。

### MoonBit 命令

| 命令 | 结果 |
| --- | --- |
| `moon check --target all --deny-warn` | 通过 |
| `moon test --target wasm --deny-warn` | 272/272 通过 |
| `moon test --target wasm-gc --deny-warn` | 272/272 通过 |
| `moon test --target js --deny-warn` | 272/272 通过 |
| `moon test --target native --deny-warn` | 272/272 通过 |
| `moon test --target all --deny-warn` | 四目标全部通过 |
| `moon build --target wasm --deny-warn` | 通过 |
| `moon build --target wasm-gc --deny-warn` | 通过 |
| `moon build --target js --deny-warn` | 通过 |
| `moon build --target native --deny-warn` | 通过 |
| `moon build --target all --deny-warn` | 四目标全部通过 |
| `moon fmt` | 通过 |
| `moon info` | 通过并刷新接口文件 |
| CLI text/table smoke test | 通过 |

本次 native 复核使用 `C:\mingw64\bin\cc.exe`，在执行 `moon clean` 后重新构建，`moon test --target native --deny-warn` 和 `moon build --target native --deny-warn` 均通过；未修改 MoonBit 安装目录中的 runtime 文件。

### README、许可证和结构

- README 已按定位、特性、快速开始、库 API、数据来源、benchmark、开发验证、贡献和许可证组织。
- README 内部表述扫描未命中竞赛流程、个人身份或本地审计对话等内部表述。
- 根目录 `LICENSE` 为 MIT。
- `_build/`、`.moon/`、`trace.json`、`.firecrawl/` 和 `.superpowers/` 已加入忽略范围或不纳入项目交付文件。
- 中国 2026 fixture 继续保留来源 URL、版本和示例边界说明。

### 申报书保护

`docs/moonbit-hackathon-application.md` 当前 SHA-256：

```text
B05B4B6CBA14C27C115A289362781F5684E0FB2EEC8EB4BFBD930DA2EE801E4D
```

本轮未修改该文件。

### Git 历史和远程默认分支

- 本地 `git rev-list --count HEAD`：31 个已有提交。
- 最近历史中的提交作者为 `chyppi`，主题覆盖日期算术、日历版本、期限计划、暂停区间和接口刷新。
- `git remote show origin`：远程 HEAD 为 `main`，本地 `main` 跟踪远程 `main`。
- 本轮已执行 `git push origin main`，远程 `main` 当前指向验收提交 `6aeee4b02ad40d2909bf8fdfd17f3f67a9fbef86`。

### Benchmark

`pwsh -File scripts/run-benchmark.ps1 -Iterations 100` 实际运行成功，结果保存在 [docs/benchmarks/latest.md](benchmarks/latest.md)，包括工具链版本、运行日期、checksum 和外层耗时。checksum 为：

```text
calendar: 48818044
deadline: 73967272
batch: 73983800
```

耗时只适用于本机运行记录，不作为跨平台保证。

## 结论分类

- 已满足：有效 MoonBit 源码规模、四目标 check/test/build、边界测试、CLI、benchmark、README、MIT 许可证、来源说明、CI 配置和默认分支只读审计。
- native 环境复核：此前 Windows MinGW 的 `rand_s` 错误本次已不再复现，当前本地四目标验证全部通过。
- GitHub 推送和 Mooncakes 发布均已完成；本报告记录的是最终本地与远程验收证据。
- 工程信息保留在 README、CHANGELOG、设计说明、基线记录和本报告中；构建产物与本地缓存不进入交付树。
