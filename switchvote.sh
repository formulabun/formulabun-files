#!/bin/bash

dir="load"

fileA="k_formulabun_vote_A.wad"
fileB="k_formulabun_vote_B.wad"

if [ -L $dir/$fileA ]
then
  rm $dir/$fileA
  ln -s $fileB $dir
else
  rm $dir/$fileB
  ln -s $fileA $dir
fi
