#!/bin/bash
# run chrisley weather app - christopher.ley@ibm.com

path=/var/www/weather

# Kill previous process
 
ps=`pgrep node`

if [ -z "${ps}" ]; then
	echo "chrisley's weather app is not running"
	echo "starting app..."
	# Launch chrisley's weather app
	nohup /usr/bin/node /var/www/weather/bin/www >> /var/www/weather/weather.log >/dev/null 2>&1 &
else
	echo "chrisley's app is running with PID:" ${ps}
	echo "restarting app..."
	kill -15 ${ps}
	sleep 1
	# Launch chrisley's weather app
	nohup /usr/bin/node /var/www/weather/bin/www >> /var/www/weather/weather.log >/dev/null 2>&1 &
fi
