#!/bin/bash

base="/home/srb2kart/mods/fbun/"
dir="load/"

fileA="k_formulabun_vote_A*.wad"
fileB="k_formulabun_vote_B*.wad"

cd $base$dir

if [ -L $fileA ]
then
  rm $fileA
  ln -s $base$fileB .
else
  rm $fileB
  ln -s $base$fileA .
fi
