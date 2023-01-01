#!/bin/bash
export PRIVATEKEY="unseal.key"
export PUBLICKEY="unseal.crt"

openssl req -x509 -nodes -newkey rsa:4096 -keyout "$PRIVATEKEY" -out "$PUBLICKEY" -subj "/CN=sealed-secret/O=sealed-secret"

