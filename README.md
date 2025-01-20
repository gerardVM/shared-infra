# Shared Infra

This repository provides backend S3 buckets and other AWS resources that may be used by several projects. Note that since the backend S3 buckets are created here, no dedicated S3 bucket for storing state files is available yet. As a result, state files are encrypted and stored within this repository.

## Encryption

This project uses encrypted configuration and terraform state files. To work with encrypted files you need to install [sops](https://github.com/mozilla/sops/releases).

## Workflow usage

Decrypt your configuration files.
```bash
make decrypt-configs
```
And once you are done, you can re-encrypt the files.
```bash
make encrypt-configs
```

## Manual usage

Decrypt your configuration and state files.
```bash
make decrypt-configs
make decrypt-tfstate AWS_ACCOUNT=<your_aws_account>
```

And then you are ready to plan and apply your terraform setup
```bash
make tf-plan AWS_ACCOUNT=<your_aws_account> AWS_PROFILE=<your_profile>
make tf-apply AWS_ACCOUNT=<your_aws_account> AWS_PROFILE=<your_profile>
```

Once you are done, you can re-encrypt the files.
```bash
make encrypt-configs
make encrypt-tfstate AWS_ACCOUNT=<your_aws_account>
```

## License

[MIT](LICENSE.txt)
