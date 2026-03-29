#!/bin/bash
set -e

WORKDIR="${GITHUB_WORKSPACE}/${INPUT_WORKING_DIRECTORY}"

echo "Using Terraform directory: $WORKDIR"
cd "$WORKDIR"

echo "Running terraform fmt check..."
terraform fmt -check -recursive

echo "Running terraform init..."
terraform init -backend=false

echo "Running terraform validate..."
terraform validate

echo "Terraform checks passed."