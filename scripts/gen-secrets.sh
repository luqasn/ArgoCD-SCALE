#!/bin/bash

set -e
set -o pipefail
set -o nounset

kubectl create secret generic cloudflare-api-token \
  --from-literal=api-token=${CLOUDFLARE_API_TOKEN} \
	-n argo-common -o yaml --dry-run=client \
	| kubeseal --format=yaml --cert=./secrets/unseal.crt \
  > ./secrets/templates/cloudflare-api-token.sealed.yaml

