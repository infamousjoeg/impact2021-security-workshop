#!/bin/bash
set -eou pipefail

docker compose down --remove-orphans
rm -rf ./opt/app/*
rm -rf ./opt/mysql/*