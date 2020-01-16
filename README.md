# docker-sfdx-cli
 
Dockerfile to create basic image for use with SalesforceDX on GitLab CI/CD 8 or others ). Originally forked from https://github.com/salestrip/docker-sfdx-cli

Lightweight Docker image using node alpine.

Includes:
- jq for shell JSON parsing
- gettext for text file processing
- ca-certificates, openssl for test result and artifact storage on CircleCI
- openssh for CircleCI SSH access
- SalesforceDX CLI from NPM
- ENVironment is already set for CI/CD pipelines
- Plugin called Scratcher included to allow Unlocked Packaging facilitation.
- Uses BASH instead of SH
- Includes python3 for scripting

Image on docker hub: https://hub.docker.com/r/depill/sfdx-cli/

[![Docker Automated build](https://img.shields.io/docker/automated/depill/sfdx-cli.svg)](https://hub.docker.com/r/depill/sfdx-cli/builds/)

Image is automatically rebuilt on new releases of:
- sfdx-cli (NPM package)
- node:alpine (root image)
