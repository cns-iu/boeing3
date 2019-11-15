#!/bin/bash

# Ensure appropriate owner on file
chown shiny:shiny /home/shiny/.Renviron

#echo 'Renviron file..'
echo "$(</home/shiny/.Renviron)"

echo 'Starting shiny-server'
/usr/bin/shiny-server.sh
