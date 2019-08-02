# usage: calc_timesync.py <pkt_size> <tx_log_file> <rx_log_file>
# usage example:
#   calc_timesync.py 0x4fe tx.txt rx.txt
# log example:
# tx side:
#tx len2:0x4fe, seq:0xec2, timedomain:0x30, timestampH:0x11, timestampL:0xa3e2df3d
#rx len2:0x4fe, seq:0xc53, timedomain:0x30, timestampH:0x11, timestampL:0xa3e8657b

#rx side:
#rx len2:0x4fe, seq:0xec2, timedomain:0x30, timestampH:0x11, timestampL:0xb213786f
#tx len2:0x4fe, seq:0xc53, timedomain:0x30, timestampH:0x11, timestampL:0xb218fa33

import sys
import subprocess
import os
import re
from shutil import copyfile

pkt_len=int(sys.argv[1], 16)
tx_file=sys.argv[2]
rx_file=sys.argv[3]
result_file="result_timesync.csv"
result_file_merge="result_timesync_merge.csv"

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
result_file_merge_stream=open(result_file_merge, 'w')

array_t23_seq=[]
array_t23_seq2=[]
array_t23_timeH=[]
array_t23_timeL=[]
array_t23_timeH2=[]
array_t23_timeL2=[]

RX_LOG_PATTERN=r"rx len2:0x(.*), seq:0x(.*), timedomain:(.*), timestampH:0x(.*), timestampL:0x(.*)"
TX_LOG_PATTERN=r"tx len2:0x(.*), seq:0x(.*), timedomain:(.*), timestampH:0x(.*), timestampL:0x(.*)"

result_file_stream.write(str("pattern") + "\t")
result_file_stream.write(str("seq1") + "\t")
result_file_stream.write(str("seq2") + "\t")
result_file_stream.write(str("time1") + "\t")
result_file_stream.write(str("time2")+"\t")
result_file_stream.write("\n")

result_file_merge_stream.write(str("pattern") + "\t")
result_file_merge_stream.write(str("seq1") + "\t")
result_file_merge_stream.write(str("seq2") + "\t")
result_file_merge_stream.write(str("time1") + "\t")
result_file_merge_stream.write(str("time2") + "\t")
result_file_merge_stream.write(str("time3") + "\t")
result_file_merge_stream.write(str("time4") + "\t")
result_file_merge_stream.write("\n")

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

        array_t23_seq.append(cur_seq);
        array_t23_seq2.append(cur_seq2);
        array_t23_timeH.append(cur_timeH);
        array_t23_timeL.append(cur_timeL);
        array_t23_timeH2.append(cur_timeH2);
        array_t23_timeL2.append(cur_timeL2);
        break

result_file_stream.write("\n")

found_last_match_t23_idx = -1
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

        #found the matched t1/2/3/4
        if ( found_last_match_t23_idx == -1):
            start_idx = 0
        else:
            start_idx = found_last_match_t23_idx

        while (start_idx < len(array_t23_seq)) :
            if (array_t23_seq[start_idx] == cur_seq and array_t23_seq2[start_idx] == cur_seq2):
                found_last_match_t23_idx = start_idx
                result_file_merge_stream.write(str("t1234") + "\t")
                result_file_merge_stream.write(str("0x%x" %cur_seq) + "\t")
                result_file_merge_stream.write(str("0x%x" %cur_seq2) + "\t")
                result_file_merge_stream.write(str("0x%x%x" %(cur_timeH, cur_timeL)) + "\t")
                result_file_merge_stream.write(str("0x%x%x" %(array_t23_timeH[start_idx], array_t23_timeL[start_idx])) + "\t")
                result_file_merge_stream.write(str("0x%x%x" %(array_t23_timeH2[start_idx], array_t23_timeL2[start_idx])) + "\t")
                result_file_merge_stream.write(str("0x%x%x" %(cur_timeH2, cur_timeL2)) + "\t")
                result_file_merge_stream.write("\n")

            start_idx = start_idx + 1
        break

tx_file_stream.close()
rx_file_stream.close()
result_file_stream.close()
print("the result is in the file %s" %result_file)
