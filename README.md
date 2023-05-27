# Centralized Infra

This repository provides backend buckets and other resources that may be used by several repositories.

## Installation

```bash
make tf-deploy
make tf-destroy
```

## Encryption

This project is prepared to work with either encrypted on unencrypted config.yaml and terraform.tfstate. To work with encrypted files you need to install [sops](https://github.com/mozilla/sops/releases), encrypt your config.yaml file with following command:
```bash
sops -e --kms <kms-key-arn> --input-type yaml config.yaml > config.enc.yaml
```
and set `ENCRYPTED` variable to `true` in the `Makefile`.

## License

[MIT](LICENSE.txt)