## Copyright 2020 Red Hat, Inc.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

-include Makefile.overrides

MAISTRA_VERSION ?= 1.1.0
IMAGE           ?= docker.io/maistra/istio-ubi8-operator-metadata:${MAISTRA_VERSION}
REGISTRY_IMAGE  ?= docker.io/maistra/maistra-registry:latest
CONTAINER_CLI   ?= docker
JAEGER_BRANCH   ?= v1.17.1
KIALI_BRANCH    ?= v1.12

# Override to use a specific fork
MAISTRA_REPO     ?= Maistra/istio-operator
# Override to use specific branches/tags, e.g.: maistra-1.0.8 maistra-1.1
MAISTRA_BRANCHES ?= maistra-1.0 maistra-1.1

# The following variables should not be overridden
SOURCE_DIR     := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OUT_DIR        = ${SOURCE_DIR}/tmp/_output
DOWNLOAD_DIR   = ${OUT_DIR}/downloads

export SOURCE_DIR OUT_DIR DOWNLOAD_DIR

################################################################################
# clean ./tmp/_output
################################################################################
.PHONY: clean
clean:
	rm -rf "${OUT_DIR}"

################################################################################
# update-csvs downloads and replaces the csv files in ./manifests
################################################################################
.PHONY: update-csvs
update-csvs:
	MAISTRA_REPO="${MAISTRA_REPO}" "${SOURCE_DIR}/build/update-csvs.sh" ${MAISTRA_BRANCHES}


################################################################################
# image builds a manifest image
################################################################################
.PHONY: image
image:
	${CONTAINER_CLI} build --no-cache -t "${IMAGE}" "${SOURCE_DIR}"

################################################################################
# registry-image builds a manifest registry image and outputs a
# configsource.yaml into ./tmp/_output/ for installing the image into an
# OpenShift cluster.
################################################################################
.PHONY: registry-image
registry-image:
	${CONTAINER_CLI} build --pull-always --no-cache --build-arg JAEGER_BRANCH=${JAEGER_BRANCH} --build-arg KIALI_BRANCH=${KIALI_BRANCH} -t "${REGISTRY_IMAGE}" -f "${SOURCE_DIR}/test/Dockerfile.registry" "${SOURCE_DIR}"
	sed -e "s+REGISTRY_IMAGE+${REGISTRY_IMAGE}+" "${SOURCE_DIR}/test/catalogsource.template" > "${OUT_DIR}/catalogsource.yaml"
