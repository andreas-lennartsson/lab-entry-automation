import time
import sys
import os
import string
import re
sys.path.append('../../sauce/pyhive')
from hive.adb import AdbClient, AdbDevice


class GetCpuLoad(object):
    '''
    classdocs
    '''


    def __init__(self, percentage=True):
        self.percentage = percentage
        self.cpustat = '/proc/stat'
        self.sep = ' '
        self.last_read = None

    def getcputime(self, device):
        '''
        http://stackoverflow.com/questions/23367857/accurate-calculation-of-cpu-usage-given-in-percentage-in-linux
        read in cpu information from file
        The meanings of the columns are as follows, from left to right:
            0cpuid: number of cpu
            1user: normal processes executing in user mode
            2nice: niced processes executing in user mode
            3system: processes executing in kernel mode
            4idle: twiddling thumbs
            5iowait: waiting for I/O to complete
            6irq: servicing interrupts
            7softirq: servicing softirqs

        #the formulas from htop
             user    nice   system  idle      iowait irq   softirq  steal  guest  guest_nice
        cpu  74608   2520   24433   1117073   6176   4054  0        0      0      0


        Idle=idle+iowait
        NonIdle=user+nice+system+irq+softirq+steal
        Total=Idle+NonIdle # first line of file for all cpus

        CPU_Percentage=((Total-PrevTotal)-(Idle-PrevIdle))/(Total-PrevTotal)
        '''
        cpu_infos = {} #collect here the information

        cpu_line = device.shell_command("su -c 'cat /proc/stat | grep -m1 \"\"'").decode("utf-8")

        cpu_array = re.findall(r'\d+', cpu_line)
        user = int(cpu_array[0])
        nice = int(cpu_array[1])
        system = int(cpu_array[2])
        idle = int(cpu_array[3])
        iowait = int(cpu_array[4])
        irq = int(cpu_array[5])
        softirq = int(cpu_array[6])
        steal = int(cpu_array[7])
        guest = int(cpu_array[8])
        guest_nice = int(cpu_array[9])

        Idle=idle+iowait
        NonIdle=user+nice+system+irq+softirq+steal

        cpu_id = "tot_cpu"

        Total=Idle+NonIdle
        #update dictionionary
        cpu_infos.update({cpu_id:{'total':Total,'idle':Idle}})
        return cpu_infos

    def getcpuload(self, device):
        '''
        CPU_Percentage=((Total-PrevTotal)-(Idle-PrevIdle))/(Total-PrevTotal)

        '''
        if (self.last_read == None):
            self.last_read = self.getcputime(device)
            return None
        else:
            stop = self.getcputime(device)

        cpu_load = {}

        CPU_Percentage = 0.0

        for cpu in self.last_read:
            Total = stop[cpu]['total']
            PrevTotal = self.last_read[cpu]['total']

            Idle = stop[cpu]['idle']
            PrevIdle = self.last_read[cpu]['idle']
            CPU_Percentage=((Total-PrevTotal)-(Idle-PrevIdle))/(Total-PrevTotal)*100
            cpu_load.update({cpu: CPU_Percentage})
        self.last_read = stop
        return CPU_Percentage


class ProcessInfo():
    def __init__(self, pid, name):
        self.pid = pid
        self.name = name


def get_process_info(process_list, device):
    try:
        process_list[:] = []
        lines = device.shell_command("su -c 'ps | grep mobi.infolife.ezweather.widget.ripple2'").decode("utf-8")
        lines = lines.split('\n')
        for line in lines:
            line_item=line.split()
            if(len(line_item) > 0 ):
                process_list.append(ProcessInfo(line_item[1], line_item[8]))
    except:
        pass
    return

def write_data(process_list, device, cpu_obj):
    current_file = os.getcwd() + "/open_file_handles.csv"

    out_file = open(current_file, 'a')

    try:
        out_line = time.ctime() + "|"
        for process in process_list:
            cmd_str="su -c 'ls /proc/" + process.pid + "/fd/ | wc -l'"
            file_handles = device.shell_command(cmd_str).decode("utf-8").translate(str.maketrans('', '', string.whitespace))
            out_line += process.name + "|" + file_handles + "|"
        total_usage=device.shell_command("su -c 'cat /proc/sys/fs/file-nr'").decode("utf-8")
        total_usage = total_usage.split()
        out_line += total_usage[0] + "|" + total_usage[2] + "|"

        out_line += str(cpu_obj.getcpuload(device))
        print(cpu_obj.getcpuload(device))



        mem_string = device.shell_command("su -c 'cat /proc/meminfo | grep -m2 \"\"'").decode("utf-8")
        mem_array = re.findall(r'\d+', mem_string)
        out_line += "|" + mem_array[1]
    except:
        pass
    print(out_line)
    out_file.write(out_line + "\n")
    out_file.close()
    return


def main():
    process_array = []
    adb_host = os.getenv('HOST_IP', default='127.0.0.1')
    adb_client = AdbClient(adb_host)
    device = AdbDevice(adb_client)
    get_process_info(process_array, device)
    cpu_obj = GetCpuLoad()
    cpu_obj.getcpuload(device)

    while(1):
        write_data(process_array, device, cpu_obj)
        time.sleep(3)
    

if __name__ == "__main__": main()
