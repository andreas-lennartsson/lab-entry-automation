#!/usr/bin/env python3.4

import sys
import os
from subprocess import call

def write_zip_file(src_file, dest_file):
    call(['zip', dest_file, src_file])

def unzip_file(src_file, dest_folder):
    call(['unzip', src_file, "-d", dest_folder])

total_length = 0
prefix = "file_parts_"
postfix = ".log"
max_file_size=1000000
file_count = 0


#Create output directory
dest_folder = directory = os.getcwd() + "/log_files"
if not os.path.exists(dest_folder):
    os.makedirs(dest_folder)

# loop throgh all zip fies and unzip them to this directory
file_name = os.getcwd() + "/" + prefix + str(file_count) + ".zip"
while os.path.isfile(file_name):
    unzip_file(file_name, dest_folder)
    file_count += 1
    file_name = os.getcwd() + "/" + prefix + str(file_count) + ".zip"

# concat all the files
