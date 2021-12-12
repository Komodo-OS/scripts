#!/bin/bash

cwd=$(pwd)
REMOTE=komodo
ROM_PATH=$cwd
XML_PATH=snippets/komodo.xml

komodo="https://github.com/Komodo-OS"
dudu="https://github.com/BiancaProject"

for i in success failed dont
do
  rm -f $i > /dev/null
  touch $i
done

repos="$(grep "remote=\"$REMOTE\"" $ROM_PATH/.repo/manifests/$XML_PATH  | awk '{print $2}' | awk -F '"' '{print $2}')"

arg=$1

agit() {
  echo "git $@"
}

for REPO in $repos; do
  if [ ! -d $REPO ]
  then
    echo $REPO >> $cwd/dont
    continue
  fi
  #echo $REPO

  case $arg in
    "remote")
      cd $REPO
      git remote rm ko
      git remote add ko $komodo/$(echo $REPO | sed "s|/|_|g")
      git remote add dudu $dudu/android_$(echo $REPO | sed "s|/|_|g")
      cd $cwd
      ;;

    "push")
      cd $REPO
      if ! git push -u ko 12
      then
        rm failed
        echo $REPO >> $cwd/failed
      else
        rm success
        echo $REPO >> $cwd/success
      fi
      cd $cwd
      sleep 1
      ;;

    "fetch")
      cd $REPO
      git fetch $2 $3
      cd $cwd
  esac
done
