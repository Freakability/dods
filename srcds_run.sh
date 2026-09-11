#!/bin/bash

set -axe

CONFIG_FILE="/home/lan/srcds/startup.cfg"

if [ -r "${CONFIG_FILE}" ]; then
    # TODO: make config save/restore mechanism more solid
    set +e
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
    set -e
fi

EXTRA_OPTIONS=( "$@" )

EXECUTABLE="/home/lan/srcds/srcds_run"
GAME="${GAME:-dod}"
MAXPLAYERS="${MAXPLAYERS:-32}"
START_MAP="${START_MAP:-dod_donner}"
SERVER_NAME="${SERVER_NAME:-KRIIIIIEG DoD:S}"
FRIENDLY_FIRE="${FRIENDLY_FIRE:-1}"

OPTIONS=( "-game" "${GAME}" "+maxplayers" "${MAXPLAYERS}" "+map" "${START_MAP}" "+hostname" "\"${SERVER_NAME}\"" "+mp_friendlyfire" "${FRIENDLY_FIRE}" )

if [ -z "${RESTART_ON_FAIL}" ]; then
    OPTIONS+=('-norestart')
fi

if [ -n "${SERVER_PASSWORD}" ]; then
    OPTIONS+=("+sv_password" "${SERVER_PASSWORD}")
fi

if [ -n "${RCON_PASSWORD}" ]; then
    OPTIONS+=("+rcon_password" "${RCON_PASSWORD}")
fi

#if [ -n "${ADMIN_STEAM}" ]; then
#    echo "\"STEAM_${ADMIN_STEAM}\" \"\"  \"abcdefghijklmnopqrstu\" \"ce\"" >> "/home/lan/srcds/dod/addons/amxmodx/configs/users.ini"
#fi

set > "${CONFIG_FILE}"

exec "${EXECUTABLE}" "${OPTIONS[@]}" "${EXTRA_OPTIONS[@]}"
