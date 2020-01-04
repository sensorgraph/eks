#!/bin/bash

helm install --generate-name external-secrets/kubernetes-external-secrets --set env.AWS_REGION=eu-west-3