#!/bin/bash

VM1="192.168.0.76"
VM2="192.168.0.68"
VM3="192.168.0.42"

SSH_USER="userx"

gnome-terminal -- bash -c "ssh $SSH_USER@$VM1; exec bash" &

gnome-terminal -- bash -c "ssh $SSH_USER@$VM2; exec bash" &

gnome-terminal -- bash -c "ssh $SSH_USER@$VM3; exec bash" &

wait
