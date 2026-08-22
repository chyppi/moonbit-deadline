# Contributing

## Before opening a change

Please describe the rule or calendar behavior being changed and add a focused test for it. Calendar data changes should include the source, jurisdiction and effective version.

Run the same checks used by CI:

```bash
moon check --deny-warn
moon test --target wasm-gc --deny-warn
moon run cmd/deadline -- --start 2026-08-07 --rule business-days:5 --exclude-start --extension following --explain
moon fmt
moon info
git diff --exit-code
```

Keep commits small enough to explain the behavior they introduce. Add tests before changing behavior and keep the public API independent from the CLI. Do not commit generated `_build` output, private calendar data, credentials or legal advice.
