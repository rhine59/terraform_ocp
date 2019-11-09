#!/bin/sh
ssh-keygen -f "/root/.ssh/known_hosts" -R 10.134.214.155
ssh root@10.134.214.155
