# Contributing

## Before opening a change

Please describe the rule or calendar behavior being changed and add a focused test for it. Calendar data changes should include the source, jurisdiction and effective version.

Run the same checks used by CI:

```bash
moon check --deny-warn
moon test --deny-warn
moon fmt --check
moon info
git diff --exit-code
```

Keep commits small enough to explain the behavior they introduce. Do not commit generated `_build` output, private calendar data, credentials or legal advice.
