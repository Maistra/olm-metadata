#!/usr/bin/env bash

set -e

# operator github repo
: ${MAISTRA_REPO:=Maistra/istio-operator}

# root src directory
: ${SOURCE_DIR:=$(pwd)}
# output directory
: ${OUT_DIR:=${SOURCE_DIR}/tmp/_output}
# download directory
: ${DOWNLOAD_DIR:=${OUT_DIR}/downloads}

# location of manifest files (this where the downloaded manifests will eventually go)
MANIFESTS_DIR="${SOURCE_DIR}"

function retrieveMaistraOperatorRelease() {
  if [ ! -f "${DOWNLOAD_DIR}/${OPERATOR_ARCHIVE_FILE}" ] ; then
    (
      if [ ! -f "${DOWNLOAD_DIR}" ] ; then
        mkdir -p "${DOWNLOAD_DIR}"
      fi
      echo "downloading Maistra Operator release: ${OPERATOR_ARCHIVE_URL}"
      cd "${DOWNLOAD_DIR}"
      curl -Lfo "${OPERATOR_ARCHIVE_FILE}" "${OPERATOR_ARCHIVE_URL}"
    )
  fi

  (
      echo "extracting Maistra Operator manifests to ${EXTRACT_DIR}"
      rm -rf ${EXTRACT_DIR}
      mkdir -p "${EXTRACT_DIR}"
      cd "${DOWNLOAD_DIR}"
      ${EXTRACT_CMD}
      cp -rf istio-operator-${MAISTRA_BRANCH}/manifests-* ${EXTRACT_DIR}/
      rm -rf istio-operator-${MAISTRA_BRANCH}
  )
}
function cleanManifestsDir() {
  find "${MANIFESTS_DIR}/manifests" -mindepth 1 -maxdepth 1 -type d |xargs -rt rm -rf
  mkdir -p ${MANIFESTS_DIR}/manifests
}

function updateManifests() {
  cp -rf ${EXTRACT_DIR}/manifests-maistra/* ${MANIFESTS_DIR}/manifests
}

USAGE="Usage: $0 branch1 branch2 ...branchN
    For example: $0 maistra-1.0 maistra-1.1"

if [ "$#" == "0" ]; then
	echo "$USAGE"
	exit 1
fi

cleanManifestsDir

while (( "$#" )); do
  MAISTRA_BRANCH="$1"
  echo "Updating manifests from ${MAISTRA_BRANCH}"
  (
    OPERATOR_ARCHIVE_FILE="${MAISTRA_REPO}/${MAISTRA_BRANCH}.zip"
    OPERATOR_ARCHIVE_FILE="${OPERATOR_ARCHIVE_FILE//\//_}"
    OPERATOR_ARCHIVE_URL="https://github.com/${MAISTRA_REPO}/archive/${MAISTRA_BRANCH}.zip"
    EXTRACT_CMD="unzip ${OPERATOR_ARCHIVE_FILE} istio-operator-${MAISTRA_BRANCH}/manifests-* -x */*package.yaml"
    EXTRACT_DIR="${DOWNLOAD_DIR}/manifests-${MAISTRA_BRANCH}"

    retrieveMaistraOperatorRelease
    updateManifests
  )
  shift
done
