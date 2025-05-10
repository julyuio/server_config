# Dont forget to backup uniq_iplist.txt first
# input files shoud be new and it outputs to uniq_iplist.txt 

import sys
import os

#set variables
threashold      =3
input_file      =''
output_file     ='output.txt'

#___________Start of Script_______________
if len(sys.argv) > 1:
	input_file = sys.argv[1]
	print(f"Filename '{input_file}' was provided as an argument.")
else:
	print("No filename provided as an argument.")
	pass

try:
	# Open the file for reading
	with open(input_file, 'r') as file:
    		ips = file.readlines()
except:
	print('you are missing the input_file !')
	check_arguments()
	pass

iplist = []
octects_list=[]
processed_ips=[]
count=0

# Create iplist and octate list
for ip in ips:
    ip = ip.strip()
    iplist.append(ip)
    octets = ip.split('.')
    octects_list.append(octets)
    #print(f'IP: {ip}, Octets: {octets}')

# Iterate throughthe list
for i in range(len(ips)):
    if count>0:
        count=count-1
        continue
    ip = iplist[i]
    if len(octects_list[i][0])>0:
        o0 = octects_list[i][0]
        o1 = octects_list[i][1]
        o2 = octects_list[i][2]
    count=0
    total_count=0
    flag24 = False
    flag16 = False
    for j in range (i+1,len(ips)):
        if (octects_list[j][0]!=o0):
            break

        if (octects_list[j][0]==o0) and (octects_list[j][1]!=o1):
            break

        if (octects_list[j][0]==o0) and (octects_list[j][1]==o1) and (octects_list[j][2]==o2):
            count = count +1
            flag24 = True
            continue
        if (octects_list[j][0]==o0) and (octects_list[j][1]==o1) and (octects_list[j][2]!=o2):
            count = count +1
            flag16 = True
            continue
    if (flag16==False) and (flag24==False):
            ip=iplist[i]
            if count>0:
                break
            else:
                if (ip):
                    processed_ips.append(ip)
    if (count>=threashold) and flag16:
            ip=o0+'.'+o1+'.0.0/16'
            processed_ips.append(ip)
            flag16=False
            flag24=False
            total_count=total_count+count+1
    if (count>=threashold) & flag24:
            ip=o0+'.'+o1+'.'+o2+'.0/24'
            processed_ips.append(ip)
            flag24=False
            total_count=total_count+count+1

    if (count>0) and (count <threashold):
          processed_ips.append(ip)
          total_count=total_count+count
          count=0

# print statistics 
#print(f'Total IPs:{len(ips)}')
#print(f'Total replaced:{len(ips)-len(processed_ips)}')


# Save the processed IPs back to file
with open(output_file, 'w') as file:
    for ip in processed_ips:
        #file.write(ip + '\n')
        print(ip)

