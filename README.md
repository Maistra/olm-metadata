# olm-metadata
This project contains OLM (Operator Lifecycle Manager) metadata for the Maistra operator.

# Development

This project relies on OLM manifests contained within the [Maistra/istio-operator](https://github.com/Maistra/istio-operator)
project.  Development on CSV files for each major.minor version should occur in
the respective `maistra-<major>.<minor>` branch in `istio-operator`.  The
rationale behind this is that the CSV (cluster service version) files include
specific details related to the operator's Deployment, Role, and
CustomResourceDefinition resources.

## Project Structure

The `./manifests` directory contains the CSV files downloaded from various
`istio-operator` branches (for example [maistra-1.0/manifests-maistra](https://github.com/Maistra/istio-operator/tree/maistra-1.0/manifests-maistra)).

## Makefile Targets

`update-csvs` downloads the latest version of CSV files from all the branches
listed in `MAISTRA_BRANCHES`.  This will overwrite all CSV files in
`./manifests`.  For example: `MAISTRA_BRANCHES="maistra-1.0 maistra-1.1" make update-csvs`

`image` will build an OLM manifest image using the contents of `./manifests`.

See the [Makefile](./Makefile) for specific details.
