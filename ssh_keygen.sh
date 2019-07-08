#!/bin/bash

if [[ $1 && $2 ]]
then
    ssh-keygen -t rsa -f ./$1 -b 2048  -C "$2"
else
    echo 'Usage: ./keygen.sh filename-for-key comment-for-key';
fi