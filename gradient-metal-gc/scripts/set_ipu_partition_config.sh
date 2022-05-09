#!/bin/bash

#ToDo add jq validation to do this stuff
vipu-admin get partition $(hostname) --ipuof-configs | tail -n +2 > /etc/ipuof.conf.d/$(hostname).config