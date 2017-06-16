#!/usr/bin/env python3.4

import sys
import os
import signal
import re
import datetime
from subprocess import call
from collections import OrderedDict

def main():
    csv_file = os.getcwd() + "/log_data_sh.csv"
    input_file_name = os.getcwd() + "/open_files_log.txt"
    input_file = open(input_file_name, 'r')
    rec_count = 0
    total_count = 0
    pid_state = False

    pid_list = {}

    for line in input_file:
        if re.search('OPEN', line):
            if len(pid_list) > 0:
                out_line = str(rec_count) + "|"
                # Sort it
                ordered_dict = OrderedDict(sorted(pid_list.items(), key=lambda t: t[1], reverse=True))
                count = 0;

                for pid in ordered_dict:
                    out_line += pid + "|" + str(ordered_dict[pid]) + "|"
                    if (count >= 5):
                        break
                    count += 1

                out_line += total_count

                # Write it
                out_file = open(csv_file, 'a')
                out_file.write(out_line + "\n")
                out_file.close()

                print(out_line)
                # Delete it
                pid_list = {}
                total_count = 0
                rec_count += 1

            pid_state = False
            continue

        elif re.search('PIDs', line):
            pid_state = True
            continue
        elif pid_state:
                number_array = re.findall(r'\d+', line)
                ppid_number = ""
                open_files = 0
                if (len(number_array) == 1):
                    if re.search('self', line):
                        ppid_number = "selfe"
                    else:
                        ppid_number = "unknown"
                    open_files = int(number_array[0])
                else:
                    open_files = int(number_array[1])
                    ppid_number = number_array[0]
                if(open_files > 0):
                    pid_list[ppid_number] = open_files
        else:
            # This is the total
            line_array = line.split()
            total_count = line_array[0]


if __name__ == "__main__": main()






