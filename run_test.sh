#!/bin/bash

PWD=`pwd`
NJOBS=$((`nproc` / 4))

mkdir results

docker build -t jant-test .

docker run -v $PWD/results:/results jant-test bash -c "make -s -j$NJOBS test | tee /results/results.txt && cp -r test /results"