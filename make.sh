#!/bin/bash
# Based on Bajee's buildscripts (It made life easier. :) )
# get current path
reldir=`dirname $0`
cd $reldir
DIR=`pwd`
DATE=$(date +%h-%d-%y)
LOG_DIR=logs

# Colorize and add text parameters
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset

DEVICE="$1"
SYNC="$2"
THREADS="$3"
CLEAN="$4"

# Initial Startup
res1=$(date +%s.%N)
echo -e "${cya}This machine is gonna build - ${bldcya}slim ROM${txtrst}";

# Unset CDPATH variable if set
if [ "$CDPATH" != "" ]
then
  unset CDPATH
fi

# create log dir if not already present
if test ! -d "$LOG_DIR"
    echo "log directory doesn't exist, creating now"
    then mkdir -p "$LOG_DIR"
fi

# Sync the latest LIQUID Sources
echo -e ""
if [ "$SYNC" == "sync" ]
then
   if [ "$(which repo)" == "" ]
   then
      if [ -f ~/bin/repo ]
        then
        echo "Y U NO install repo?!"
        mkdir ~/bin
        export PATH=~/bin:$PATH
        curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > ~/bin/repo
        chmod a+x ~/bin/repo
      fi
   fi
   echo -e "${bldblu}Syncing latest slim && MIRAGE sources ${txtrst}"
   repo sync -f -j"$THREADS"
   echo -e ""
fi

# Setup Environment (Cleaning)
if [ "$CLEAN" == "clean" ]
then
   echo -e "${bldblu}Cleaning up out folder ${txtrst}"
   make clobber;
else
  echo -e "${bldblu}Skipping out folder cleanup ${txtrst}"
fi

# Setup Environment
echo -e "${bldblu}Setting up build environment ${txtrst}"
. build/envsetup.sh

if [ "$DEVICE" == "all" ]
then
   echo -e ""
   echo -e "${bldblu}Starting to build the epic ROM ${txtrst}"
   echo -e "${bldblu}crespo ${txtrst}"
   lunch "slim_crespo-userdebug"
   make -j"$THREADS" otapackage
   echo -e "${bldblu}grouper ${txtrst}"
   lunch "slim_grouper-userdebug"
   make -j"$THREADS" otapackage
   echo -e "${bldblu}Maguro ${txtrst}"
   lunch "slim_maguro-userdebug"
   make -j"$THREADS" otapackage
   echo -e "${bldblu}mako ${txtrst}"
   lunch "slim_mako-userdebug"
   make -j"$THREADS" otapackage
   echo -e "${bldblu}toro ${txtrst}"
   lunch "slim_toro-userdebug"
   make -j"$THREADS" otapackage
else
   # Lunch Device
   echo -e ""
   echo -e "${bldblu}Lunching your device ${txtrst}"
   lunch "slim_$DEVICE-userdebug";

   echo -e ""
   echo -e "${bldblu}Starting to build the epic ROM ${txtrst}"

   # Start Building like a bau5
   mka bacon TARGET_TOOLS_PREFIX=`pwd`/android-toolchain-eabi/bin/arm-linux-androideabi- TARGET_PRODUCT=slim_maguro
   echo -e ""
fi

# Once building completed, bring in the Elapsed Time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"

