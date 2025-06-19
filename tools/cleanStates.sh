#!/bin/bash

find ../ \( -name ".terraform" -o -name ".terraform.lock.hcl" -o -name "terraform.tfstate" -o -name "terraform.tfstate.backup" \) -exec rm -Rf {} \;