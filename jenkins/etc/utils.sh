# my Time
export TZ=":Asia/Jakarta"
# Colors makes things beautiful
export TERM=xterm

red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
blu=$(tput setaf 4)             #  blue
cya=$(tput setaf 6)             #  cyan
txtrst=$(tput sgr0)             #  Reset

# Time function
function timeStart() {
	DATELOG=$(date "+%H%M-%d%m%Y")
	BUILD_START=$(date +"%s")
	DATE=`date`
}

function timeEnd() {
	BUILD_END=$(date +"%s")
	DIFF=$(($BUILD_END - $BUILD_START))
}