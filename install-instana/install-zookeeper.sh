#!/bin/bash

export PATH=".:$PATH"

install-zookeeper-operator.sh
check_return_code $?

install-zookeeper-apply-cr.sh
check_return_code $?
