## how to use this

```shell
dir="$(jj root)/overlays/plexpass"
sops exec-env $dir/secrets.yaml $dir/update.sh
```
