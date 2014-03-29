#!/bin/sh

hadoop fs -rm input
hadoop fs -rmr output
hadoop fs -put ./input input
hadoop jar /usr/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.0.0-mr1-cdh4.5.0.jar \
-input /user/`whoami`/input \
-output /user/`whoami`/output \
-numReduceTasks 1 \
-mapper "./mapper.rb" \
-reducer "./reducer.rb" \
-file mapper.rb \
-file reducer.rb
