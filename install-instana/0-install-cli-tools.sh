#!/bin/bash

export PATH=".:$PATH"

# instana plugin
0-install-kubectl-plugin.sh

# yq
0-install-yq.sh

# helm
0-install-helm.sh
