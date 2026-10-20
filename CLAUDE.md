# Project: saalab-claude
AWS SAA-C03 练习用的 Terraform 项目。

## Rules
- Region: ap-southeast-1
- 所有资源名字用 `saalab-` 前缀，所有资源都要打 tag `Project=saa-lab`（用 provider 的 default_tags）
- 只写 Terraform，不要直接用 AWS CLI 创建资源
- 绝对不要执行 `terraform apply` 或 `terraform destroy`，由我手动执行
- 改完代码后执行 `terraform fmt` 和 `terraform validate`
- 优先选最便宜的方案：t3.micro，单 AZ，单个 NAT Gateway
- 解释用中文
