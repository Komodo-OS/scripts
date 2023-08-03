#!/bin/bash

# Copyright (C) 2019-2020 @alanndz (Telegram and Github)
# Copyright (C) 2020 @KryPtoN
# SPDX-License-Identifier: GPL-3.0-or-later

# use_ccache=
# YES - use ccache
# NO - don't use ccache
# CLEAN - clean your ccache (Do this if you getting Toolchain errors related to ccache and it will take some time to clean all ccache files)

# make_clean=
# YES - make clean (this will delete "out" dir from your ROM repo)
# NO - make dirty
# INSTALLCLEAN - make installclean (this will delete all images generated in out dir. useful for rengeneration of images)

# gapps=
# gapps - build with gapps
# microg - build with microg
# nogapps

# lunch_command
# LineageOS uses "lunch lineage_devicename-userdebug"
# AOSP uses "lunch aosp_devicename-userdebug"
# So enter what your uses in Default Value
# Example - du, xosp, pa, etc

# device_codename
# Enter the device codename that you want to build without qoutes
# Example - "hydrogen" for Mi Max
# "armani" for Redmi 1S

# build_type
# userdebug - Like user but with root access and debug capability; preferred for debugging
# user - Limited access; suited for production
# eng - Development configuration with additional debugging tools

# target_command
# bacon - for compiling rom
# bootimage - for compiling only kernel in ROM Repo
# Settings, SystemUI for compiling particular APK

# upload_to_sf
# relase - upload on sourceforge release folder
# test - upload on sourceforge test folder

# Default setting, uncomment if u havent jenkins
# use_ccache=yes # yes | no | clean
# make_clean=yes # yes | no | installclean
# gapps=gapps
# lunch_command=komodo
# device_codename=lavender
# build_type=userdebug
# target_command=bacon
# jobs=8
# upload_to_sf=release

CDIR=$PWD
OUT="${CDIR}/out/target/product/$device_codename"
ROM_NAME="KomodoOS"
DEVICE="$device_codename"

path_ccache="${CDIR}/.ccache"

. ${CDIR}etc/utlis.sh
. ${CDIR}etc/telegram.sh
. ${CDIR}etc/checker.sh
. ${CDIR}etc/progress.sh
. ${CDIR}etc/message.sh

#######

# Verify important
if [ "$BOT_API_KEY" = "" ]; then
  echo -e ${cya}"Bot Api not set, please setup first"${txtrst}
  exit 2
fi
if [ "$CHAT_ID" = "" ]; then
  echo -e ${cya}"Env CHAT_ID not set, please setup first"${txtrst}
  exit 4
fi
if [ "$CHAT_ID_SECOND" = "" ]; then
  echo -e ${cya}"CHAT_ID_SECOND not set, please setup first"${txtrst}
fi

#########

# Time Start
timeStart

##############

# Verification Environment
if [ "$SF_PASS_RELEASE" = "" ]; then
  echo -e ${cya}"SF_PASS_RELEASE not set, please setup first"${txtrst}
  exit 3
fi
if [ "$SF_PASS_TEST" = "" ]; then
  echo -e ${cya}"SF_PASS_TEST not set, please setup first"${txtrst}
  exit 5
fi
if [ "$BRANCH_MANIFEST" = "" ]; then
  echo -e ${cya}"BRANCH_MANIFEST not set, please setup first"${txtrst}
  exit 8
fi
###################

if [ "$re_sync" = "yes" ]; then
    build_message "Sync repo"
    rm -rf external/motorola/faceunlock .repo/local_manifests
    rm -rf frameworks/base packagages/apps/Settings
    repo init -u https://github.com/Komodo-OS-Rom/manifest -b $BRANCH_MANIFEST
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
    git clone git@github.com:Komodo-OS-Rom/external_fu.git -b ten external/motorola/faceunlock
    external/motorola/faceunlock/regenerate/regenerate.sh
fi

# Build Variant

if [ "$upload_to_sf" = "release" ]; then
    export KOMODO_VARIANT=RELEASE
fi

if [ "$upload_to_sf" = "test" ]; then
    export KOMODO_VARIANT=BETA
fi

# BUILD Variant

if [ "$gapps" = "gapps" ]; then
    export CURRENT_BUILD_TYPE=gapps
fi

if [ "$gapps" = "nogapps" ]; then
    export CURRENT_BUILD_TYPE=nogapps
fi

if [ "$gapps" = "microg" ]; then
    export CURRENT_BUILD_TYPE=microg
fi

# CCACHE UMMM!!! Cooks my builds fast

if [ "$use_ccache" = "yes" ]; then
	echo -e ${blu}"CCACHE is enabled for this build"${txtrst}
	export CCACHE_EXEC=$(which ccache)
	export USE_CCACHE=1
	export CCACHE_DIR=$path_ccache
	ccache -M 50G
fi

if [ "$use_ccache" = "clean" ]; then
	export CCACHE_EXEC=$(which ccache)
	export CCACHE_DIR=$path_ccache
	ccache -C
	export USE_CCACHE=1
	ccache -M 50G
	wait
	echo -e ${grn}"CCACHE Cleared"${txtrst};
fi

# Its Clean Time
if [ "$make_clean" = "yes" ]; then
        build_message "make clean"
	make clean # && make clobber
	wait
	echo -e ${cya}"OUT dir from your repo deleted"${txtrst};
fi

# Its Images Clean Time
if [ "$make_clean" = "installclean" ]; then
        build_message "make installclean"
	make installclean
	wait
	echo -e ${cya}"Images deleted from OUT dir"${txtrst};
fi

BUILDLOG="$CDIR/out/${ROM_NAME}-${DEVICE}-${DATELOG}.log"
# time to build bro
build_message "Staring broo...🔥"
source build/envsetup.sh
build_message "lunch komodo_"$device_codename"-"$build_type""
lunch komodo_"$device_codename"-"$build_type"
mkfifo reading
tee "${BUILDLOG}" < reading &
build_message "masak "$target_command" -j"$jobs""
sleep 2
build_message "🛠️ Building..."
progress &
masak "$target_command" -j"$jobs" > reading

# Record exit code after build
retVal=$?
timeEnd
statusBuild
tg_send_document --chat_id "$CHAT_ID" --document "$BUILDLOG" --reply_to_message_id "$CI_MESSAGE_ID"

# Detecting file
FILENAME=$(cat $CDIR/out/var-file_name)
if [ "$target_command" = "komodo" ]; then
    #FILEPATH=$(find "$OUT" -iname "${ROM_NAME}*${DEVICE}*zip")
    FILEPATH="$OUT/$FILENAME.zip"
elif [ "$target_command" = "bootimage" ]; then
    FILEBOOT=$(find "$OUT" -iname "boot.img" 2>/dev/null)
        build_message "Zipping $target_command"
    FILEPATH="out/$target_command.zip"
    zip -r9 "$FILEPATH" "$FILEBOOT"
    build_message "Sending to telegram"
    tg_send_document --chat_id "$CHAT_ID" --document "$FILEPATH" --reply_to_message_id "$CI_MESSAGE_ID"
    build_message "Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds
Build Success ❤️"
    exit 0
else
    build_message "Zipping $target_command"
    FILEAPPS=$(find "$OUT/system" -type d -iname "$target_command" 2>/dev/null)
    FILEPATH="out/$target_command.zip"
    zip -r9 "$FILEPATH" "$FILEAPPS"
    build_message "Sending to telegram"
    tg_send_document --chat_id "$CHAT_ID" --document "$FILEPATH" --reply_to_message_id "$CI_MESSAGE_ID"
    build_message "Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.
Build Success ❤️"
    exit 0
fi

if [ "$upload_to_sf" = "release" ]; then
    build_message "Uploading to sourceforge release 📤"
    sshpass -p "$SF_PASS_RELEASE" sftp -oBatchMode=no komodos@frs.sourceforge.net:/home/frs/project/komodos-rom > /dev/null 2>&1 <<EOF
cd $DEVICE
put $FILEPATH
exit
EOF
    build_message "Uploaded on : https://sourceforge.net/projects/komodos-rom/files/$DEVICE/$FILENAME.zip/download
Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
fi

if [ "$upload_to_sf" = "test" ]; then
    build_message "Uploading to sourceforge test 📤"
    sshpass -p "$SF_PASS_TEST" sftp -oBatchMode=no kry9ton@frs.sourceforge.net:/home/frs/project/krypton-project > /dev/null 2>&1 <<EOF
cd Test
put $FILEPATH
exit
EOF
    build_message "Uploaded on : https://sourceforge.net/projects/krypton-project/files/Test/$FILENAME.zip/download
Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
fi

exit 0