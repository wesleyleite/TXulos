urlencode() {
    local STRING="$@"
    local NSTRING=""
    local CHARLIST="\"\'\$\%\&\,\\\;\/:<>^\`\{\}\|\@\[\]\="

    [ ! -z "${STRING}" ] && {
        for POS in $( seq 0 $((${#STRING}-1)) )
        do
            CHAR="${STRING:${POS}:1}"
            case "${CHAR}" in 
                [${CHARLIST}])
                    NSTRING="${NSTRING}%$(str2hex "${CHAR}")"
                ;;
                *)
                    NSTRING="${NSTRING}${STRING:${POS}:1}"
                ;;
            esac
        done
    } || printf "${USAGE}"
    echo ${NSTRING} | sed 's/ /%20/g'
}

