---
name: scalingo-run
description: Exécuter un script Ruby (rails runner) sur une app Scalingo et lire sa sortie, quand scalingo run perd le quoting ou échoue sans TTY.
---

# Running Ruby on Scalingo

`scalingo run` rejoins argv with spaces on the remote side, so local quoting is lost: inline Ruby (`rails runner '...'`) fails with `syntax error near unexpected token`. Without a TTY, interactive `run` also fails (`make stdin raw`). Encode the script in base64 and run it detached:
```bash
B64=$(base64 < script.rb | tr -d '\n')
scalingo -a <app> run --detached "echo $B64 | base64 -d | bundle exec rails runner /dev/stdin"
# then read the one-off container output:
scalingo --region osc-fr1 --app <app> logs -n 300 | grep one-off-XXXX
```
