#!/bin/bash

# First verify that SEC has started like that
# sec --detach --conf=/etc/sec/hw2_short.rules --input=/etc/sec/input_short.log --log=/etc/sec/output_short.log

# Fill out the parameters and also check that intervals in the RULES match (these have been shortened for testing purposes!)
pid="2639" # SEC PID
input="input_short.log" # input log file SEC is watching
output="output_short.log" # SEC output

# tests to run (1 for yes, 0 for no)
task2=1
task3=1

echo "clear output.log and delete /tmp/sec.dump"
echo "" > $output
rm -f /tmp/sec.dump

echo "sending HUP signal to $pid (reload)"
kill -s HUP $pid

sleep 1 # give SEC some time to reinit

# Test for task 2
# RULES: Probing for 10 secs with minimum 5 secs interval, noisy port should be active at least 15 secs
if [ $task2 -eq 1 ]; then
echo "Starting test for task2 (Probing port for 15 minutes (10 secs in tests)"
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=25 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
sleep 1
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=23421 DF PROTO=TCP SPT=34342 DPT=25 WINDOW=29200 RES=0x00 SYN URGP=0" >> $input
sleep 6
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=23421 DF PROTO=TCP SPT=34342 DPT=25 WINDOW=29200 RES=0x00 SYN URGP=0" >> $input
# there shouldn be any noisy port yet, counting for 21 starts after next event
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=31442 DF PROTO=TCP SPT=47846 DPT=21 WINDOW=49640 RES=0x00 SYN URGP=0" >> $input
sleep 4
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.93 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=17209 DF PROTO=TCP SPT=11652 DPT=21 WINDOW=7290 RES=0x00 SYN URGP=0" >> $input

# lets start probing UDP/100  too
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=31442 DF PROTO=UDP SPT=47846 DPT=100 WINDOW=49640 RES=0x00 SYN URGP=0" >> $input

sleep 4
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=31442 DF PROTO=TCP SPT=47846 DPT=21 WINDOW=49640 RES=0x00 SYN URGP=0" >> $input

echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=31442 DF PROTO=UDP SPT=47846 DPT=100 WINDOW=49640 RES=0x00 SYN URGP=0" >> $input

sleep 3
echo $(date -u) "TEST: ---> NOISY PORT TCP/21 SHOULD BE RAISED" >> $output
sleep 1
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=31442 DF PROTO=TCP SPT=47846 DPT=21 WINDOW=49640 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=31442 DF PROTO=UDP SPT=47846 DPT=100 WINDOW=49640 RES=0x00 SYN URGP=0" >> $input
sleep 3
echo $(date -u) "TEST: ---> NOISY PORT UDP/100 SHOULD BE RAISED" >> $output

# Start a new 10 secs probing cycle for UDP/100 to extend the life of noisy port
sleep 1
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=31442 DF PROTO=UDP SPT=47846 DPT=100 WINDOW=49640 RES=0x00 SYN URGP=0" >> $input
sleep 4
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=31442 DF PROTO=UDP SPT=47846 DPT=100 WINDOW=49640 RES=0x00 SYN URGP=0" >> $input
sleep 4
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.1.1.7 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=31442 DF PROTO=UDP SPT=47846 DPT=100 WINDOW=49640 RES=0x00 SYN URGP=0" >> $input
sleep 2
echo $(date -u) "TEST: ---> NOISY PORT TCP/21 SHOULD BE DROPPED" >> $output
echo $(date -u) "TEST: ---> NOISY PORT UDP/100 SHOULD BE CREATED (SET NEW LIFETIME)" >> $output

if [ $task3 -eq 0 ]; then
# we won't continue probing, so lets wait to see that NOISY port will be removed correctly
# otherwise we'll UDP/100 as a NOISY
sleep 15
echo $(date -u) "TEST: ---> NOISY PORT UDP/100 SHOULD BE DROPPED" >> $output
sleep 2
fi

echo "task 2 done"
fi

if [ $task3 -eq 1 ]; then
# if some host probes 5 different ports within 60 seconds, so that none of the probed ports has been memorized as noisy within the last 1 hour, send an e-mail about the offending host to root@localhost.
# RULES: test assumes that if theres 6 sec gap between probes, then offender candidate will be dropped
# RULES: if offender is declared, then offenders should be ignored for at least 12 secs, 15+ to be sure!
echo "Starting test for task3 (probing 5 different hosts)"

#10.6.6.6 will be detected as an offending host
#10.9.9.9 wont be detected at first, but will  during the its 3rd burst
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=25 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=25 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=26 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=26 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input

sleep 2
echo $(date -u) "TEST: ---> 10.6.6.6 probes fifth time, but this time it just extends the lifetime of NOISY UDP/100" >> $output
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=100 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input

sleep 2
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=666 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo $(date -u) "TEST: ---> 10.6.6.6 SHOULD BE DETECTED - PORTS TCP/25 to UDP/666" >> $output

sleep 3
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.9.9.9 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=90 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.9.9.9 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=91 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.9.9.9 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=92 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.9.9.9 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=93 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=93 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input

sleep 7
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.9.9.9 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=94 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.9.9.9 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=95 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
sleep 2
echo $(date -u) "TEST: ---> NOISY PORT UDP/100 SHOULD BE DROPPED" >> $output
sleep 2
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.9.9.9 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=96 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.9.9.9 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=97 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.9.9.9 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=98 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input

sleep 1
echo $(date -u) "TEST: ---> 10.9.9.9 SHOULD BE DETECTED - PORTS UDP/94 to UDP/98" >> $output

sleep 2
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=60 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=61 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=62 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=63 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.6.6.6 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=UDP SPT=16333 DPT=64 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo $(date -u) "TEST: ---> 10.6.6.6 SHOULD NOT BE DETECTED ANYMORE" >> $output

sleep 3
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.2.2.2 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=60 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.2.2.2 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=61 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.2.2.2 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=62 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
sleep 3
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.2.2.2 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=63 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.3.3.3 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=64 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
# should NOT be offensive
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.3.3.3 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=65 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.3.3.3 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=66 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
sleep 2
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.4.4.4 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=64 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.4.4.4 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=64 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input
echo "localhost kernel: iptables: IN=eth0 OUT= MAC=X SRC=10.4.4.4 DST=10.13.25.59 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=1881 DF PROTO=TCP SPT=16333 DPT=64 WINDOW=5840 RES=0x00 SYN URGP=0" >> $input

sleep 5
echo "task 3 done"
fi

echo "Running dump"
kill -s SIGUSR1 $pid
echo "Dump created at /tmp/sec.dump"