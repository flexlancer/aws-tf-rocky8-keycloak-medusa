#!/usr/bin/env bash

set -euo pipefail

echo ""
echo "========================================================"
echo "==         STARTING KEYCLOAK CONFIGURATION            =="
echo "========================================================"

BASEDIR=$(dirname "$0")
source $BASEDIR/keycloak-configuration-helpers.sh

if [ "$KCADM" == "" ]; then
    KCADM=$KEYCLOAK_HOME/bin/kcadm.sh
    echo "Using $KCADM as the admin CLI."
fi

$KCADM config credentials --server http://$HOST_FOR_KCADM:8080/auth --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD --realm master

source $BASEDIR/realms.sh

echo "========================================================"
echo "==            KEYCLOAK CONFIGURATION DONE             =="
echo "========================================================"
echo ""
