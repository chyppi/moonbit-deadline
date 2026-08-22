# moonbit-deadline 本地验收自查报告

生成日期：2026-08-22

本报告按八月黑客松口径整理，参考公开的 [`osc2026-guide`](https://github.com/Milky2018/osc2026-guide) 检查项和 [MoonBit 社区 workflow templates](https://github.com/moonbit-community/.github/tree/main/workflow-templates)。本轮只做本地修改和只读远程审计，不执行 GitHub 推送、GitLink 写操作或 Mooncakes 发布。

## 总体判断

本地仓库已经具备可运行的 MoonBit 库、CLI、边界测试、benchmark、许可证和 CI 配置。有效 `.mbt` 源码规模已超过 8,000 行，核心可移植目标检查/测试/构建通过。

仍需在具备合适外部环境后完成的事项：

- Mooncakes 实际发布尚未执行，本轮按任务要求保留为后续动作。
- 本轮改动尚未推送到 GitHub；工作区存在有意的本地修改和新增文件。
- 当前 Windows 使用 MinGW `cc.exe` 时，MoonBit runtime native 目标因 `rand_s` 声明不兼容失败；这不是仓库 MoonBit 源码诊断错误，CI 已对 Windows 采用 wasm/wasm-gc/js 便携目标，Unix 保留全目标验证。

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
files=128 lines=9983 tests=273
```

统计排除了 `pkg.generated.mbti`、`_build`、`.moon`、`target` 和 `node_modules`；行数来自实际 `.mbt` 文件读取，不是 README 声明。

### MoonBit 命令

| 命令 | 结果 |
| --- | --- |
| `moon check --target all --deny-warn` | 通过 |
| `moon test --target wasm --deny-warn` | 273/273 通过 |
| `moon test --target wasm-gc --deny-warn` | 273/273 通过 |
| `moon test --target js --deny-warn` | 273/273 通过 |
| `moon build --target wasm --deny-warn` | 通过 |
| `moon build --target wasm-gc --deny-warn` | 通过 |
| `moon build --target js --deny-warn` | 通过 |
| `moon fmt` | 通过 |
| `moon info` | 通过并刷新接口文件 |
| CLI text/table smoke test | 通过 |

Windows native 的实际失败为：

```text
C:\Users\gunter\.moon\lib\runtime\env.c:181:9:
error: implicit declaration of function 'rand_s'
```

verbose 命令确认编译器为 `C:\mingw64\bin\cc.exe`。因此没有把 native 失败伪装成通过，也没有修改 MoonBit 安装目录中的 runtime 文件。

### README、许可证和结构

- README 已按定位、特性、快速开始、库 API、数据来源、benchmark、开发验证、贡献和许可证组织。
- README 内部表述扫描未命中“申报人”“结项”“唯一贡献者”“未修改申报书”“远程同步”等词。
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
- 本轮没有执行 `git push`；因此远程仍是本轮修改前的状态。

### Benchmark

`pwsh -File scripts/run-benchmark.ps1 -Iterations 100` 实际运行成功，结果保存在 [docs/benchmarks/latest.md](benchmarks/latest.md)，包括工具链版本、运行日期、checksum 和外层耗时。checksum 为：

```text
calendar: 48818044
deadline: 73967272
batch: 73983800
```

耗时只适用于本机运行记录，不作为跨平台保证。

## 结论分类

- 已满足：有效 MoonBit 源码规模、可移植目标 check/test/build、边界测试、CLI、benchmark、README、MIT 许可证、来源说明、CI 配置和默认分支只读审计。
- 已知环境问题：当前 Windows MinGW native runtime 的 `rand_s` 声明兼容性。
- 待外部动作：提交本地改动、推送 GitHub、执行 Mooncakes 发布；这些动作本轮按要求没有执行。
