#!/usr/bin/env bash

set -euo pipefail

######################
### Setup realms via their script
######################

echo "setting up realms..."

source $BASEDIR/realm_master.sh
source $BASEDIR/realm_myrealm.sh
