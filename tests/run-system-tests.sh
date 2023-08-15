#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

db=${db:-mysql}
pg=${pg:-latest}
my=${my:-latest}
php=${php:-latest}
e=${e:-}
t=${t:-}
j=${j:-}
b=${b:-chrome}

while [ $# -gt 0 ]; do
	 if [[ $1 == "-"* ]]; then
		param="${1/-/}"
		declare $param="$2"
	 fi
	shift
done

if [ -z $e ]; then
	echo "No extension found!"
	exit
fi

if [ ! -d $(dirname $0)/www ]; then
	mkdir $(dirname $0)/www
fi

# Stop the containers
if [ -z $t ]; then
	docker-compose -f $(dirname $0)/docker-compose.yml stop
fi

# Run VNC viewer
if [[ $(command -v vinagre) ]]; then
	( sleep 15; vinagre localhost > /dev/null 2>&1 ) &
fi

# What a simple test should be executed, do a simple run
args="run"
if [ -z $t ]; then
	# Recreate to prevent that some containers are created with the last parameters
	args="up --force-recreate"
fi

# Run the tests
if [ -z $j ]; then
	EXTENSION=$e TEST=$t JOOMLA=3 DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b docker-compose -f $(dirname $0)/docker-compose.yml $args system-tests
	EXTENSION=$e TEST=$t JOOMLA=4 DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b docker-compose -f $(dirname $0)/docker-compose.yml $args system-tests
else
	EXTENSION=$e TEST=$t JOOMLA=$j DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b docker-compose -f $(dirname $0)/docker-compose.yml $args system-tests
fi

# Stop the containers
if [ -z $t ]; then
	docker-compose -f $(dirname $0)/docker-compose.yml stop
fi
