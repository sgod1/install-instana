#!/bin/bash

BIN_URL_LINUX_AMD64="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
BIN_URL_LINUX_ARM64="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
BIN_URL_DARWIN_AMD64="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
BIN_URL_DARWIN_ARM64="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"

mkdir linux-amd64
mkdir linux-arm64
mkdir darwin-amd64
mkdir darwin-arm64


