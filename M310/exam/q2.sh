#!/bin/bash

openssl x509 -in "$HOME/shared/certs/client.pem" -text -nameopt RFC2253
