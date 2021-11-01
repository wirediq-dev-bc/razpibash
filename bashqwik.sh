#!/bin/bash

# shtemplate.sh: Generate basic shell script with 755 permissions


Prog_error () {
	local _PROGNAME="${0##*/}"
	local _ERROR="${1}"
	local _NAME="${2}"
	local _ERR=
	
	if [[ "${_ERROR}" == 'z' ]]; then
		_ERR="Name required to generate new script."
	elif [[ "${_ERROR}" == 'e' ]]; then
		_ERR="Filename already exists: ${_NAME}"
	elif [[ "${_ERROR}" == 'r' ]]; then
		_ERR="Filename Regex Failed: ${_NAME}"
	fi
	
	[ -n "${_ERR}" ] && printf "\n${_ERR}\n"
	printf "\nusage: ${_PROGNAME} <unique_name>\n\n"
	exit 1	
}


Gen_template () {
	local VALID="$(pwd)/${1}"

	touch "${VALID}" && { 
		echo '#!/bin/bash' >> "${VALID}";
		echo -e '\n' >> "${VALID}";
		echo "# ${1}: " >> "${VALID}";
	} && chmod 755 "${VALID}"
}


Validate_input () {
	local VALIDATE="${1}"

	case "${VALIDATE}" in 
		-h | --help ) 
			Prog_error 
			;;
	esac

	if [ -z "${VALIDATE}" ]; then
		Prog_error 'z'

	elif [[ ! "${VALIDATE}" =~ ^(\.|\_)?([[:alnum:]]+|\-*)+(\.sh)?$ ]]; then
		Prog_error 'r' "${VALIDATE}"

	elif [ -e "$(pwd)/${VALIDATE}" ]; then
		Prog_error 'e' "${VALIDATE}"
	fi
}


Validate_input "${1}" && 
	Gen_template "${1}" && 
	vim "${1}"












