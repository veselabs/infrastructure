<!-- prettier-ignore-start -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 6.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github_repositories"></a> [github\_repositories](#module\_github\_repositories) | ../../modules/github-repository | n/a |
| <a name="module_iam_oidc_provider"></a> [iam\_oidc\_provider](#module\_iam\_oidc\_provider) | terraform-aws-modules/iam/aws//modules/iam-oidc-provider | ~> 6.2.1 |
| <a name="module_iam_role_github_oidc_read"></a> [iam\_role\_github\_oidc\_read](#module\_iam\_role\_github\_oidc\_read) | terraform-aws-modules/iam/aws//modules/iam-role | ~> 6.2.1 |
| <a name="module_iam_role_github_oidc_write"></a> [iam\_role\_github\_oidc\_write](#module\_iam\_role\_github\_oidc\_write) | terraform-aws-modules/iam/aws//modules/iam-role | ~> 6.2.1 |

## Resources

| Name | Type |
|------|------|
| [github_membership.veselyn](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/membership) | resource |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
<!-- prettier-ignore-end -->
