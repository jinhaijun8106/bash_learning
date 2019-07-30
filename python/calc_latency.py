# usage: calc_latency.py <pkt_size> <tx_log_file> <rx_log_file>
# usage example:
#   calc_latency.py 0x4ef tx.txt rx.txt
# log example:
#rx len2:0x4fe, seq:f90, timedomain:30, timestampH:0x3, timestampL:0x4917ae54
#tx len2:0x0, seq:be4, timedomain:30, timestampH:0x3, timestampL:0x491dc732

import sys
import subprocess
import os
import re

pkt_len=int(sys.argv[1], 16)
tx_file=sys.argv[2]
rx_file=sys.argv[3]
result_file="result_latency.csv"



print("parsing len:%s, tx file:%s, rx file:%s" % (pkt_len, tx_file, rx_file))

if not os.path.isfile(tx_file):
    print ("File doesn't exist: %s" %tx_file)
    sys.exit(1)

if not os.path.isfile(rx_file):
    print ("File doesn't exist: %s" %rx_file)
    sys.exit(1)


worksheet_stream = open (result_file, 'w')
tx_file_stream=open(tx_file, 'r')
rx_file_stream=open(rx_file, 'r')

RX_LOG_PATTERN=r"rx len2:0x(.*), seq:0x(.*), timedomain:(.*), timestampH:0x(.*), timestampL:0x(.*)"
TX_LOG_PATTERN=r"tx len2:0x(.*), seq:0x(.*), timedomain:(.*), timestampH:0x(.*), timestampL:0x(.*)"

found_new_pattern = 0
while 1:
    #find the rx packet in the rx logs
    if (found_new_pattern == 0):
        line = rx_file_stream.readline()
        if not line:
            break
    check_log=re.match(RX_LOG_PATTERN, line);
    if(check_log == None):
        print("no match, ignore this line");
        continue
    cur_len=int(check_log.group(1), 16)
    cur_seq=int(check_log.group(2), 16)
    cur_timeH=int(check_log.group(4), 16)
    cur_timeL=int(check_log.group(5), 16)
    if (cur_len != pkt_len):
        print("ignore the len:%x %x" % (cur_len, pkt_len));
        continue
    print("found rx pattern, seq:%x" % cur_seq);
    #print("line:%s" % line);
    #find the tx packet in the rx logs
    found_new_pattern = 0
    while 1:
     	line = rx_file_stream.readline()
    	if not line:
        	break
        #found new rx
        check_log=re.match(RX_LOG_PATTERN, line);
        if(check_log != None):
            print("found new rx");
            found_new_pattern = 1
            break
    	check_log=re.match(TX_LOG_PATTERN, line);
    	if(check_log == None):
                #print("no match tx")
        	continue
        cur_len2=int(check_log.group(1), 16)
    	cur_seq2=int(check_log.group(2), 16)
    	cur_timeH2=int(check_log.group(4), 16)
    	cur_timeL2=int(check_log.group(5), 16)
        if (cur_len2 != pkt_len):
            print("ignore the len2:%x %x" % (cur_len2, pkt_len));
            continue
	print("found pattern t2t3 rx_seq tx_seq %x %x %x%x %x%x" %(cur_seq, cur_seq2, cur_timeH,cur_timeL, cur_timeH2,cur_timeL2))
        break

found_new_pattern = 0
while 1:
    #find the tx packet in the tx logs
    if (found_new_pattern == 0):
        line = tx_file_stream.readline()
        if not line:
            break
    check_log=re.match(TX_LOG_PATTERN, line);
    if(check_log == None):
        print("no match, ignore this line");
        continue
    cur_len=int(check_log.group(1), 16)
    cur_seq=int(check_log.group(2), 16)
    cur_timeH=int(check_log.group(4), 16)
    cur_timeL=int(check_log.group(5), 16)
    if (cur_len != pkt_len):
        print("ignore the len:%x %x" % (cur_len, pkt_len));
        continue
    print("found tx pattern, seq:%x" % cur_seq);
    #print("line:%s" % line);
    #find the tx packet in the rx logs
    found_new_pattern = 0
    while 1:
     	line = tx_file_stream.readline()
    	if not line:
        	break
        #found new pattern
    	check_log=re.match(TX_LOG_PATTERN, line);
    	if(check_log != None):
                #print("no new pattern")
                found_new_pattern = 1
        	break

    	check_log=re.match(RX_LOG_PATTERN, line);
    	if(check_log == None):
                #print("no match rx")
        	continue
        cur_len2=int(check_log.group(1), 16)
    	cur_seq2=int(check_log.group(2), 16)
    	cur_timeH2=int(check_log.group(4), 16)
    	cur_timeL2=int(check_log.group(5), 16)
        if (cur_len2 != pkt_len):
            print("ignore the len:%x %x" % (cur_len2, pkt_len));
            break
	print("found pattern: t1t4 tx_seq rx_seq %x %x %x%x %x%x" %(cur_seq, cur_seq2, cur_timeH,cur_timeL, cur_timeH2,cur_timeL2))
        break

