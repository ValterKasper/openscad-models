#!/bin/sh

cat model_list | sed s/$/.png/ | xargs make