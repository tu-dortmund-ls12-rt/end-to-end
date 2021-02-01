#!/bin/bash
#

###
# Specify number of concurrent instances.
###
if [ $# -eq 0 ]
then
  echo "Specify maximal number of concurrent instances for the experiment (e.g. './auto.sh 5' )."
  exit 1
else
  var=$1
  echo "with $var concurrent instances"
fi


###
# Timing.
###
echo "===Run Experiment"
date

num_tries=5  # number of runs
runs_per_screen=5  # number of runs per screen

num_task_ind=1  # amount of different task numbers

hypers=(0 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000)  # hyperperiods to be checked
len_hypers=${#hypers[@]}  # number of elements in hypers

timeout_par=10

for ((j=0;j<num_task_ind;j++))
do
  echo "task index $j"
  for ((i=0;i<num_tries
  do
    for ((k=1;k<len_hypers;k++))
    do
      echo "start instance $((i+k))"
      screen -dmS ascr$i python3.7 runtime_tasks.py -n$i -timeout=$timeout_par -tindex=$j -r$runs_per_screen -hypermin=$((${array[$((k-1))]})) -hypermax=$((${array[$k]}))

      # wait until variable is reached
      numberrec=$(screen -list | grep -c ascr.*)
      while (($numberrec >= $var))
      do
        sleep 1
        numberrec=$(screen -list | grep -c ascr.*)
      done
    done
    #
    # echo "start instance $i"
    # screen -dmS ascr$i python3.7 runtime_tasks.py -n$i -timeout=10 -tindex=$j -r$runs_per_screen -hypermin=0 -hypermax=1000
    #
    # # wait until variable is reached
    # numberrec=$(screen -list | grep -c ascr.*)
    # while (($numberrec >= $var))
    # do
    #   sleep 1
    #   numberrec=$(screen -list | grep -c ascr.*)
    # done
    #
    # echo "start instance $((i+1))"
    # screen -dmS ascr$i python3.7 runtime_tasks.py -n$((i+1)) -timeout=10 -tindex=$j -r$runs_per_screen -hypermin=1000 -hypermax=2000
    #
    # # wait until variable is reached
    # numberrec=$(screen -list | grep -c ascr.*)
    # while (($numberrec >= $var))
    # do
    #   sleep 1
    #   numberrec=$(screen -list | grep -c ascr.*)
    # done
    #
    # echo "start instance $((i+2))"
    # screen -dmS ascr$i python3.7 runtime_tasks.py -n$((i+2)) -timeout=10 -tindex=$j -r$runs_per_screen -hypermin=2000 -hypermax=3000
    #
    # # wait until variable is reached
    # numberrec=$(screen -list | grep -c ascr.*)
    # while (($numberrec >= $var))
    # do
    #   sleep 1
    #   numberrec=$(screen -list | grep -c ascr.*)
    # done
    #
    # echo "start instance $((i+3))"
    # screen -dmS ascr$i python3.7 runtime_tasks.py -n$((i+3)) -timeout=10 -tindex=$j -r$runs_per_screen -hypermin=3000 -hypermax=4000
    #
    # # wait until variable is reached
    # numberrec=$(screen -list | grep -c ascr.*)
    # while (($numberrec >= $var))
    # do
    #   sleep 1
    #   numberrec=$(screen -list | grep -c ascr.*)
    # done
  done
done


# wait until all are closed
while screen -list | grep -q ascr.*
do
  sleep 1
done

###
# Plotting.
###
echo "===Plot data"
python3.7 runtime_tasks.py -j1 -n=$((4*num_tries))


echo "DONE"
date