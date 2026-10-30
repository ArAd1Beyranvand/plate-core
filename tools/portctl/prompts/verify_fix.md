Follow-up to portctl task {{task}} ({{title}}). The work for it is in the repo, but its oracle
(`{{oracle}}`, run in `ports/{{lang}}`) is red. First error:

```
{{error}}
```

Read `claude/port/ROADMAP.md` if you are new to this task. Fix the port and run the oracle again until it is
green. Don't weaken or delete tests. If a vector or test is wrong, say so instead.
