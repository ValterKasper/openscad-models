#!/usr/bin/python3

import os
import sys

if (len(sys.argv) != 2):
    raise Exception("Expenced one argument with extension name e.g stl png")

extension = sys.argv[1]

file1 = open('model_list', 'r')
lines = file1.readlines()

for line in lines:
    if (len(line) == 0 or line[0] == '#'):
        continue

    line_parts = line.split()
    target_file_name = line_parts[0]
    source_file_name = line_parts[0]

    parameter_set_name = "none"
    if (len(line_parts) == 2):
        parameter_set_name = line_parts[1]
        target_file_name = target_file_name + "_" + parameter_set_name

    target_file_name = target_file_name
    parameter_set_argument = "PARAMETER_SET=" + parameter_set_name
    source_file_name_argument = "SOURCE=" + source_file_name
    command = "make {} {} {}".format(target_file_name  + "." + extension, parameter_set_argument, source_file_name_argument)
    # print(command)
    os.system(command)

