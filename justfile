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
