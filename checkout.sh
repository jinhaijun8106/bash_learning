#!/bin/bash
if [ "$1" != "" ] 
then
    find -name "$1" | xargs p4 edit;
    find -name "$1" | xargs p4 edit;
fi
