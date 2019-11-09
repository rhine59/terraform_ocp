#!/bin/sh
export TF_LOG=INFO
export TF_LOG_PATH="terraform.log"
echo yes|terraform apply
