# Lists all recipes
default:
    @just --list

# Checks if the Terraform docs need to be regenerated for the environments
[group('docs')]
check-docs +environments='./environments/*':
    #!/usr/bin/env bash
    set -euxo pipefail
    for environment in {{ environments }}; do
        terraform-docs markdown table "${environment}" \
            --recursive \
            --recursive-path=../../modules \
            --output-file=README.md \
            --output-check
    done

# Generates Terraform docs for the environments
[group('docs')]
generate-docs +environments='./environments/*':
    #!/usr/bin/env bash
    set -euxo pipefail
    for environment in {{ environments }}; do
        terraform-docs markdown table "${environment}" \
            --recursive \
            --recursive-path=../../modules \
            --output-file=README.md
    done

# Locks the Terraform providers for the environments
lock-providers +environments='./environments/*':
    #!/usr/bin/env bash
    set -euxo pipefail
    for environment in {{ environments }}; do
        terraform -chdir="${environment}" providers lock \
            -platform=darwin_amd64 \
            -platform=darwin_arm64 \
            -platform=linux_amd64 \
            -platform=linux_arm64
    done
