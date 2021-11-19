#!/bin/bash

# readvols.sh: Read and inspect all local volumes to generate dump file.

Error () {
	echo "FATAL_ERROR: $1"
	exit 1
}

Volume_inspector () {
	# Inspect all volumes docker can see and create dump file in ~/tmp.
	if [[ ! "${PWD##*/}" =~ ^tmp$ && ! -e "$VOLUME_DUMP" ]]; then
		Error 'Must be in ~/tmp for volume dumps'
	else
		while read driver vol_name; do
			echo -e "DiskVol.ID: $vol_name"
			$sh_c "docker volume inspect $vol_name | sed -n ' s/^    //p' >> $VOLUME_DUMP"
		done < <(docker volume ls | tail -n +2)
	fi
}

Make_dump_file () {
	# Create ~/tmp directory if doesnt exist.
	if [ ! -d ~/tmp ]; then
		echo 'Creating ~/tmp directory'
		$sh_c mkdir ~/tmp || Error 'mkdir ~/tmp'
	fi
	cd ~/tmp || Error 'No /tmp jump'

	# If dumps already made that day (LAST), increment counter (vNUM)
	local FILENAME="dkr-vols-`date +%d-%m-%Y`" 
	VOLUME_DUMP="$FILENAME.0.json"

	if ls | grep -qE "^${FILENAME}"; then
		LAST="$(ls ~/tmp | grep -qE "^${FILENAME}" | tail -n 1 | cut -d '.' -f 2-2)"
		VOLUME_DUMP="$FILENAME.$(( LAST + 1 )).json"
		unset 'LAST'
	fi
	Volume_inspector "$VOLUME_DUMP"
}

#sh_c='echo'
sh_c='sh -c'
Make_dump_file
cat <<- EOF 		

HELO FRIEND
NEW FILE @ ~/tmp/$VOLUME_DUMP
THANK YOU
HAVE NICE DAY

EOF

