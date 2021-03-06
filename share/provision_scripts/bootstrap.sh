#!/bin/bash -x

# USER RBBT BOOTSTRAP
# ===================

for workflow in $WORKFLOWS; do
    rbbt workflow install $workflow 
done

export RBBT_WORKFLOW_AUTOINSTALL
export RBBT_LOG

for workflow in $BOOTSTRAP_WORKFLOWS; do
    echo "Bootstrapping $workflow on $BOOTSTRAP_CPUS CPUs"
    rbbt workflow cmd $workflow bootstrap --cpus $BOOTSTRAP_CPUS
done
