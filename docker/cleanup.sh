#!/bin/sh
# From https://github.com/HardySimpson/docker-cleanup

>/tmp/run_image_ids.$$

DOCKER_BIN=`which docker`
#LOG=/var/log/docker-cleanup.log

rm /tmp/run_image_ids.$$

echo "$(date) start-----"

$DOCKER_BIN ps --no-trunc -a -q | while read cid
do
  running=$($DOCKER_BIN inspect -f '{{.State.Running}}' $cid )
  if [ "$running"x = "true"x ]
  then
    id=$($DOCKER_BIN inspect -f '{{.Image}}' $cid )
    echo $id >>/tmp/run_image_ids.$$
    continue
  fi
  fini=$($DOCKER_BIN inspect -f '{{.State.FinishedAt}}' $cid | awk -F. '{print $1}')
  diff=$(expr $(date +"%s") - $(date --date="$fini" +"%s"))
  #for MacOs
  #diff=$(expr $(date +"%s") - $(date -j -f %Y-%m-%dT%H:%M:%S "$fini" +"%s"))
  if [ $diff -gt 86400 ]
  then
    cmd="$DOCKER_BIN rm -v $cid 2>&1"
    echo "running: $cmd"
    eval $cmd
  fi
done

$DOCKER_BIN images --no-trunc | grep -v REPOSITORY | while read line
do
  repo_tag=$(echo $line | awk '{print $1":"$2}')
  image_id=$(echo $line | awk '{print $3}')
  grep -q $image_id /tmp/run_image_ids.$$
  if [ $? -eq 0 ]
  then
    continue
  fi
  if [ "$repo_tag"x = "<none>:<none>"x ]
  then
    cmd="$DOCKER_BIN rmi $image_id 2>&1"
    echo "running: $cmd"
    eval $cmd
  else
    cmd="$DOCKER_BIN rmi $repo_tag 2>&1"
    echo "running: $cmd"
    eval $cmd
  fi
done

rm /tmp/run_image_ids.$$

echo "$(date) end-----"
