- never commit unless I explicitly ask you to

## Devbox Projects

For projects with a `devbox.json`, always prefix shell commands with `devbox run --` to ensure devbox-configured tools are available:
```bash
devbox run -- bb test
devbox run -- clojure -M:dev
```