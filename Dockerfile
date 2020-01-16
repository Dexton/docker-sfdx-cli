# use small node image
FROM node:alpine

# install git ca-certificates openssl openssh for CircleCI
# install jq for JSON parsing
RUN apk add --update --no-cache git openssh ca-certificates openssl jq gettext xmlstarlet curl bash python3


# install latest sfdx from npm
RUN npm install sfdx-cli --global
RUN sfdx --version
RUN sfdx plugins --core

# Set Default values for SFDX
ENV SFDX_AUTOUPDATE_DISABLE=false
ENV SFDX_JSON_TO_STDOUT=true
ENV SFDX_USE_GENERIC_UNIX_KEYCHAIN=true
ENV SFDX_DOMAIN_RETRY=true
ENV SFDX_PROJECT_AUTOUPDATE_DISABLE_FOR_PACKAGE_CREATE=true
ENV SFDX_PROJECT_AUTOUPDATE_DISABLE_FOR_PACKAGE_VERSION_CREATE=true

# revert to low privilege user
USER node

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin
WORKDIR /home/node

# Link the SFDX Plugin Scratcher
RUN git clone https://github.com/depill/sfdx-plugin-scratcher.git
RUN sfdx plugins:link sfdx-plugin-scratcher/.
