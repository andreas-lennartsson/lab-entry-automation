#!/usr/bin/env python3.4

import sys
import os
import signal
import re
import datetime
from subprocess import call
#import matplotlib.pyplot as plt
#import numpy as np
#import matplotlib.cbook as cbook

class FaultList():
    def __init__(self):
        self.error_list = {}
        self.warning_list = {}
        self.exception_list = {}
        self.fatal_list = {}
        self.boot_times = {}
        self.crash_times = {}

class Bucket():
    def __init__(self):
        self.error_count = 0
        self.warning_count = 0
        self.exception_count = 0
        self.fatal_count = 0
        self.system_start = 0
        self.system_crash = 0


stdin = sys.stdin
fault_list = FaultList()

def natural_sort(l):
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ]
    return sorted(l, key = alphanum_key)

def setup_debug():
    current_file_name = os.getcwd() + "/result_log.log"
    sys.stdin = open(current_file_name,'r')

def write_zip_file(src_file, dest_file):
    call(['zip', dest_file, src_file])

def print_list(list_to_print):
    for file_name in natural_sort(list_to_print):
        out_str = "     " + file_name + ": " + str(list_to_print[file_name])
        print(out_str)

def print_fault_report():
    print("")
    print("Fatals:")
    print_list(fault_list.fatal_list)
    print("")

    print("Errors:")
    print_list(fault_list.error_list)
    print("")

    print("Warnings:")
    print_list(fault_list.warning_list)
    print("")

    print("Exceptions:")
    print_list(fault_list.exception_list)
    print("")

    print("System Starts:")
    for file_name in natural_sort(fault_list.boot_times):
        out_str = "     " + file_name + ": " + str(fault_list.boot_times[file_name])
        print(out_str)

    print("System Crashes:")
    for file_name in natural_sort(fault_list.crash_times):
        out_str = "     " + file_name + ": " + str(fault_list.crash_times[file_name])
        print(out_str)

def signal_handler(signum, frame):
    print_fault_report()
    sys.stdin = stdin
    exit(0)

def get_time_from_line(line):
    time_obj = None
    try:
        word_array = line.split()
        time_str = word_array[0] + " " + word_array[1]
        #time.strptime('Jun 1 2005  1:33PM', '%b %d %Y %I:%M%p')
        time_obj = datetime.datetime.strptime(time_str, '%m-%d %H:%M:%S.%f')

        # 06-09 09:28:31.190
    except:
        pass
    return time_obj

def add_to_dict (dict, file_name):
    if (file_name in dict):
        dict[file_name] += 1
    else:
        dict[file_name] = 1

def write_data(data, time_stamp, csv_file):

    out_file = open(csv_file, 'a')

    try:
        out_line = time_stamp.ctime() + "|"
        out_line += str(data.error_count) + "|"
        out_line += str(data.warning_count) + "|"
        out_line += str(data.exception_count) + "|"
        out_line += str(data.fatal_count) + "|"
        out_line += str(data.system_start) + "|"
        out_line += str(data.system_crash)
    except:
        pass
    print(out_line)
    out_file.write(out_line + "\n")
    out_file.close()
    return

def main():
    total_length = 0
    prefix = "file_parts_"
    postfix = ".log"
    max_file_size = 10000000
    file_count = 0
    bucket_delta = datetime.timedelta(seconds=60)
    last_time = None
    last_date_time_secs=None
    csv_data = Bucket()
    csv_file = os.getcwd() + "/log_data.csv"

    #setup_debug()

    signal.signal(signal.SIGINT, signal_handler)
    current_file_name = os.getcwd() + "/" + prefix + str(file_count) + postfix
    out_file = open(current_file_name, 'w')

    for line in sys.stdin:
        try:
            total_length += len(line)

            time_object = get_time_from_line(line)

            if(time_object):
                current_date_time_secs = time_object
                if(last_date_time_secs):
                    time_diff = current_date_time_secs - last_date_time_secs
                    if (time_diff >= bucket_delta):
                        write_data(csv_data, current_date_time_secs, csv_file)
                        last_date_time_secs = current_date_time_secs
                        csv_data = Bucket()
                else:
                    last_date_time_secs = current_date_time_secs

            if re.search('The system died; earlier logs will point to the root cause', line, re.IGNORECASE):
                fault_list.crash_times[current_file_name] = line.rstrip()
                csv_data.system_crash += 1
            if re.search('SystemServer: Entered the Android system server!', line, re.IGNORECASE):
                fault_list.boot_times[current_file_name] = line.rstrip()
                csv_data.system_start += 1
            elif (re.search('java.lang.', line, re.IGNORECASE) and re.search('Exception', line, re.IGNORECASE)) or re.search('java.lang.Throwable', line, re.IGNORECASE):
                add_to_dict(fault_list.exception_list, current_file_name)
                csv_data.exception_count += 1
            if (line.find(" W ") >= 0):
                csv_data.warning_count += 1
                add_to_dict(fault_list.warning_list, current_file_name)
            elif (line.find(" E ") >= 0):
                csv_data.error_count += 1
                add_to_dict(fault_list.error_list, current_file_name)
            elif (line.find(" F ") >= 0):
                csv_data.fatal_count += 1
                add_to_dict(fault_list.fatal_list, current_file_name)

            out_file.write(line)
            if (total_length >= max_file_size):
                total_length = 0

                # Close current file
                out_file.close()

                # zip current file
                write_zip_file(prefix + str(file_count) + postfix, prefix + str(file_count) + ".zip")

                # Delete current file
                os.remove(current_file_name)

                file_count += 1
                current_file_name = os.getcwd() + "/" + prefix + str(file_count) + postfix

                # Open new file
                out_file = open(current_file_name, 'w')
        except:
            pass

    print_fault_report()

if __name__ == "__main__": main()






