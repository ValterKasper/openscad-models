#!/bin/sh

cat model_list | sed s/$/.stl/ | xargs make
