#!/usr/bin/python3

import sys
import getopt
import os
import textwrap

OUTPUT_DIR = "output"

def print_help():
    print(textwrap.dedent(
    """
    make_models.py -f <scad file> -s <parameter set> -e <extension> -l <model list> --clear
        Examples:
            make_models.py -f assortment_box.scad -s panel -e png
            make_models.py -l model_list -e png

        Each line in model list is in format:
            [#]<scad file> [paramater set]"""))

def process_command(scad_file_name, extension, parameter_set = None):
    target_file_name = scad_file_name
    if (parameter_set != None):
        target_file_name = target_file_name + "_" + parameter_set

    command = None
    if (extension == "stl"):
        command = f"""
        openscad {scad_file_name}.scad \
            -o {target_file_name}.{extension} \
            -P {parameter_set} \
            -p {scad_file_name}.json
        mkdir -p {OUTPUT_DIR}
        mv {target_file_name}.{extension}  {OUTPUT_DIR}/{target_file_name}.{extension}"""
    elif (extension == "png"):
        command = f"""
        openscad {scad_file_name}.scad \
            -o {target_file_name}.{extension} \
            -P {parameter_set} \
            -p {scad_file_name}.json \
            --render \
            --imgsize=1024,1024 \
            --colorscheme "Tomorrow Night"
        mkdir -p {OUTPUT_DIR}
        mv {target_file_name}.{extension}  {OUTPUT_DIR}/{target_file_name}.{extension}"""
    else:
        print(f"Unknown extension {extension}")
        print_help()
        sys.exit(2)

    print(f"""{target_file_name}.{extension}:""")
    os.system(textwrap.dedent(command))
    print("")

def remove_extension(file_name):
    return os.path.splitext(file_name)[0]

def main(argv):
    scad_file_name = None
    parameter_set = None
    extension = None
    model_list_file_name = None
    clear = False
    try:
        opts, args = getopt.getopt(argv, "hf:s:e:l:", ["clear"])
    except getopt.GetoptError:
        print_help()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print_help()
            sys.exit()
        elif opt in ("-f"):
            scad_file_name = arg
        elif opt in ("-e"):
            extension = arg
        elif opt in ("-l"):
            model_list_file_name = arg
        elif opt in ("-s"):
            parameter_set = arg
        elif opt in ("--clear"):
            clear = True

    if (clear):
        os.system(textwrap.dedent(f"""
        rm -f {OUTPUT_DIR}/*.stl
	    rm -f {OUTPUT_DIR}/*.png
        """))

    if (model_list_file_name != None):
        model_list_file = open(model_list_file_name, 'r')
        lines = model_list_file.readlines()

        for line in lines:
            if (len(line) == 0 or line[0] == '#'):
                continue

            line_parts = line.split()
            source_file_name = remove_extension(line_parts[0])

            if (len(line_parts) == 2):
                parameter_set = line_parts[1]
            else:
                parameter_set = None

            process_command(source_file_name, extension, parameter_set)
    elif (scad_file_name != None and extension != None):
        process_command(remove_extension(scad_file_name), extension, parameter_set)
    else:
        print_help()
        sys.exit(2)

if __name__ == "__main__":
    main(sys.argv[1:])
