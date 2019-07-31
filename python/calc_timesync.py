# usage: calc_timesync.py <pkt_size> <tx_log_file> <rx_log_file>
# usage example:
#   calc_timesync.py 0x4ef tx.txt rx.txt
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
result_file="result_timesync.csv"



print("parsing len:%s, tx file:%s, rx file:%s" % (pkt_len, tx_file, rx_file))

if not os.path.isfile(tx_file):
    print ("File doesn't exist: %s" %tx_file)
    sys.exit(1)

if not os.path.isfile(rx_file):
    print ("File doesn't exist: %s" %rx_file)
    sys.exit(1)


tx_file_stream=open(tx_file, 'r')
rx_file_stream=open(rx_file, 'r')
result_file_stream=open(result_file, 'w')

RX_LOG_PATTERN=r"rx len2:0x(.*), seq:0x(.*), timedomain:(.*), timestampH:0x(.*), timestampL:0x(.*)"
TX_LOG_PATTERN=r"tx len2:0x(.*), seq:0x(.*), timedomain:(.*), timestampH:0x(.*), timestampL:0x(.*)"

result_file_stream.write(str("pattern") + "\t")
result_file_stream.write(str("seq1") + "\t")
result_file_stream.write(str("seq2") + "\t")
result_file_stream.write(str("time1") + "\t")
result_file_stream.write(str("time2"))
result_file_stream.write("\n")

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
	print("found pattern t2t3 rx_seq tx_seq 0x%x 0x%x 0x%x%x 0x%x%x" %(cur_seq, cur_seq2, cur_timeH,cur_timeL, cur_timeH2,cur_timeL2))
        #buf_data = "t2t3 0x%x 0x%x 0x%x%x 0x%x%x\n" %(cur_seq, cur_seq2, cur_timeH, cur_timeL, cur_timeH2, cur_timeL2)
        result_file_stream.write(str("t2t3") + "\t")
        result_file_stream.write(str("0x%x" %cur_seq) + "\t")
        result_file_stream.write(str("0x%x" %cur_seq2) + "\t")
        result_file_stream.write(str("0x%x%x" %(cur_timeH, cur_timeL)) + "\t")
        result_file_stream.write(str("0x%x%x" %(cur_timeH2, cur_timeL2)) + "\t")
        result_file_stream.write("\n")
        break

result_file_stream.write("\n")

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
	print("found pattern: t1t4 tx_seq rx_seq 0x%x 0x%x 0x%x%x 0x%x%x" %(cur_seq, cur_seq2, cur_timeH,cur_timeL, cur_timeH2,cur_timeL2))
        result_file_stream.write(str("t1t4") + "\t")
        result_file_stream.write(str("0x%x" %cur_seq) + "\t")
        result_file_stream.write(str("0x%x" %cur_seq2) + "\t")
        result_file_stream.write(str("0x%x%x" %(cur_timeH, cur_timeL)) + "\t")
        result_file_stream.write(str("0x%x%x" %(cur_timeH2, cur_timeL2)) + "\t")
        result_file_stream.write("\n")
        break

tx_file_stream.close()
rx_file_stream.close()
result_file_stream.close()
print("the result is in the file %s" %result_file)
