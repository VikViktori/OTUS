#!/bin/bash
if grep $KEYWORD $FILE &> /dev/null
then
    logger "======> oh,monday <======"
else
    exit 0
fi

