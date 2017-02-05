#!/usr/bin/env bash

function trimString()
{
    local -r string="${1}"

    sed -e 's/^ *//g' -e 's/ *$//g' <<< "${string}"
}

function isEmptyString()
{
    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function info()
{
    local -r message="${1}"

    echo -e "\033[1;36m${message}\033[0m" 2>&1
}

function getLastAptGetUpdate()
{
    local aptDate="$(stat -c %Y '/var/cache/apt')"
    local nowDate="$(date +'%s')"

    echo $((nowDate - aptDate))
}

function runAptGetUpdate()
{
    local updateInterval="${1}"

    local lastAptGetUpdate="$(getLastAptGetUpdate)"

    if [[ "$(isEmptyString "${updateInterval}")" = 'true' ]]
    then
        # Default To 24 hours
        updateInterval="$((24 * 60 * 60))"
    fi

    if [[ "${lastAptGetUpdate}" -gt "${updateInterval}" ]]
    then
        info "apt-get update"
        apt-get update -m
    else
        local lastUpdate="$(date -u -d @"${lastAptGetUpdate}" +'%-Hh %-Mm %-Ss')"

        info "Skip apt-get update because its last run was '${lastUpdate}' ago"
    fi
}

#/////////////////////////////////////////////////
#/////////////////////////////////////////////////
#/////////////////////////////////////////////////

if  [ $(dpkg-query -W -f='${Status}' python 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "JOHN: INSTALLING (python)"
    export DEBIAN_FRONTEND=noninteractive
    runAptGetUpdate
    apt-get install -y python

elif [ $(dpkg-query -W -f='${Status}' python-simplejson 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
	runAptGetUpdate
    apt-get install -y python-simplejson
else
	echo "JOHN: Skipping python-simplejson install"
fi

#/////////////////////////////////////////////////

if [ $(dpkg-query -W -f='${Status}' ansible 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "JOHN: INSTALLING (ansible)"

        if [ $(dpkg-query -W -f='${Status}' software-properties-common 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        	echo "JOHN: INSTALLING (software-properties-common)"
            export DEBIAN_FRONTEND=noninteractive
            runAptGetUpdate
            apt-get install -y software-properties-common
        fi

    export DEBIAN_FRONTEND=noninteractive
    apt-add-repository ppa:ansible/ansible         &> /dev/null || exit 1
    runAptGetUpdate

    echo "Installing Ansible"
    apt-get install -qq ansible &> /dev/null || exit 1
    echo "Ansible installed"

  else
	echo "JOHN: Skipping ansible install"
fi

#cd /vagrant/provisioning
#ansible-playbook setup.yml --connection=locall
