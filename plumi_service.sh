#!/bin/sh

cd /plumi.app
bin/supervisord
sleep 4
bin/supervisorctl status

