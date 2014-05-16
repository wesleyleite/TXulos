#!/bin/bash

Version="0.0.1"
# control variable
sOperationMode=""
iLineCount=""
#
sUrl=""
sOptions=""
fHistory=~/.txulos
fFileName="$1"
sTarget=""
sVariable=""
sMethod="${sMethod:-GET}"
sCookie=""
sUserAgent=""
sWgetOptions=""
sFilter=""

__invoque_set()
{
    local sSetParam="$1"
    local sString="$2"

    [ ! -z "${sString}" ] && {
        case ${sSetParam} in
            target)
                sTarget="${sString}"
                ;;
            var)
                sVariable="${sVariable}${sString}"
                ;;
            method)
                sMethod="${sString}"
                ;;
            useragent)
                sUserAgent="${sString}"
                ;;
            wgetoptions)
                sWgetOptions="${sString}"
                ;;
            filter)
                sFilter="${sString}"
                ;;
            *)
                return 1
                ;;
        esac
    } || return 1
    return 0
}

__invoque_unset()
{
    local sType="$1"
    local sNameVar="$2"

    case ${sType} in
        var)
            sVariable=$(echo "${sVariable}" |
                            sed -r "s/[\&|\?]${sNameVar}=.+\&/\&/g" )
            ;;
        all)
            unset sVariable
            ;;
    esac
}

__organizer()
{
    sOptions=" --cookie='on' --save-cookies='${sCookie}' --load-cookies='${sCookie}' --keep-session-cookies "

    [ ! -z "${sUserAgent}" ] &&
        sOptions="${sOptions} --user-agent=${sUserAgent} "
    [ ! -z "${sWgetOptions}" ] &&
        sOptions="${sOptions} ${sWgetOptions}"

    case ${sMethod^^} in
        POST)
            [ "${sVariable:0:1}" != '&' -a \
                "${sVariable}" != '&'  ] && sVariable="&${sVariable}"
            [ "${sVariable:$((${#sVariable}-1)):${#sVariable}}" != "&" -a \
                "${sVariable}" != '&' ] && sVariable="${sVariable}&"

            sUrl="${sTarget}"
            sOptions="--post-data='${sVariable}' ${sOptions}"
            ;;
        GET)
            [ "${sVariable:0:1}" != '?' ] && sVariable="?${sVariable}"
            sUrl="${sTarget}${sVariable}"
            sOptions="${sOptions}"
            ;;
    esac
}

__run()
{
    [ -z "${sTarget}" -o\
        -z "${sMethod} " ] && {
        echo "Headshot : target or method not set"
        return 1
    }
    [ -f "${sCookie}" ] ||
        sCookie=$(mktemp)

    __organizer
    [ -z "${sFilter}" ] &&
        wget -q -O - ${sOptions} "${sUrl}" ||
            wget -q -O - ${sOptions} "${sUrl}" | ${sFilter}
}

__invoque_show()
{
    echo
    echo "  Target     : ${sTarget}"
    echo "  Var        : ${sVariable}"
    echo "  Method     : ${sMethod}"
    echo "  wgetOptions: ${sWgetOptions}"
    echo "  User-Agent : ${sUserAgent}"
    echo "  Filter     : ${sFilter}"
    echo
}

__invoque_history()
{
    local sOpt="$1"

    case ${sOpt^^} in
        CLEAN)
            >${fHistory}
            ;;
        *)
            more ${fHistory}
            ;;
    esac
}

__attack_var()
{
    local sAttackParam="$1"
    local sAttackVar="$2"
    local sVariablePreserver="${sVariable}"
    local sAttackString=""
    local sVarExistInVariable=""

    sVarExistInVariable=$(echo ${sVariable} |
                                    tr \& \\n |
                                    grep -E "^${sAttackVar}" )

    [ -z "${sVarExistInVariable}" -o\
        -z "${sAttackVar}" ] &&
            return 1

    while read -e -p "__ ${sAttackVar} >> " sAttackString
    do

        history -s "${sAttackString}"
        echo "${sAttackString}" >> ${fHistory}

        case ${sAttackString} in
            quit)
                break
                ;;
            show)
                __invoque_show
                ;;
            *)
                [ ! -z "${sAttackString}" ] && {
                    sVariable=$(echo "${sVariable}" |
                                sed s/${sVarExistInVariable}/${sVarExistInVariable}${sAttackString}/ )
                }
                __run
                sVariable="${sVariablePreserver}"
                ;;
        esac
   done

    sVariable=${sVariablePreserver}
    return 0
}

__check_headshot()
{
    local sHandler="$1"
    [ $? -eq 1 ] && {
        echo "Headshot ${iLineCount} : ${sHandler}"
        [ ${sOperationMode} -eq 0 ] && exit
    }
}

__help()
{
    echo " - set target      <host>"
    echo "       > set target http://www.example.com"
    echo " - set var         <variable>"
    echo "       > set var &username=xulos&password=1234&"
    echo " - set method      <method>"
    echo "       > set method POST"
    echo " - set wgetoptions <options>"
    echo "       > set wgetoptions -T 30"
    echo " - set useragent   <user-agent-string>"
    echo "       > set useragent Mozilla/5.0"
    echo " - set filter      <filter-output-data>"
    echo "       > set filter html2text"
    echo "       > set filter grep -Ewo '[a-f0-9]+'"
    echo " - attack      <variables>"
    echo "       > attack username"
    echo " - unset           <var-name|all>"
    echo "       > unset var username"
    echo "      remove variable username OR clean all"
    echo "       > unset all"
    echo " - show"
    echo "       > show"
    echo " - run"
    echo "      > run"
    echo " - history         <clean>"
    echo "      > history"
    echo "      > history clean"
    echo " - quit"
}

__invoque_hub()
{
    local sType=$(echo $1 |
                        cut -d ' ' -f1)
    local sParam=$(echo $1 |
                        cut -d ' ' -f2)
    local sStore="$(echo $1 |
                        cut -d ' ' -f3-)"

    # discard comments and blank line
    [ "${sType}" == "$(echo ${sType} | grep '^#')" -o \
        "${sType}" == "$(echo ${sType} | grep '^$')" ] && return 0

    case ${sType^^} in
        SET)
            __invoque_set "${sParam}" "${sStore}"
            __check_headshot "${sParam} ${sStore}"
           ;;
        UNSET)
            __invoque_unset "${sParam}" "${sStore}"
            __check_headshot "${sParam} ${sStore}"
            ;;
        HELP)
            __help
           ;;
        SHOW)
            __invoque_show
            ;;
        RUN)
            __run
            ;;
        HISTORY)
            [ ${sOperationMode} -eq 1 ] &&
                __invoque_history "${sParam}"
            ;;
        ATTACK)
            __attack_var "${sParam}" "${sStore}"
            __check_headshot "${sParam} ${sStore}"
            ;;
        QUIT)
            exit
            ;;
        *)
            echo -e "Headshot ${iLineCount} : ${sType}"
            [ ${sOperationMode} -eq 0 ] && exit
            ;;
    esac
}

# main
[ ! -z "${fFileName}" ] && {
    # mode read file
    sOperationMode=0

    while read line
    do
        iLineCount=0
        __invoque_hub "${line}"
        iLineCount=$((iLineCount+1))
    done < ${fFileName}
} || {
    # interactive mode with prompt
    sOperationMode=1
    [ ! -e ${fHistory} ] && >${fHistory}

    echo -e "TXulos ${Version}\nhelp for more information"

    set -o emacs
    bind 'set show-all-if-ambiguous on'
    bind 'set completion-ignore-case on'

    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    bind 'TAB:dynamic-complete-history'
    declare -a sComandos
    sComandos=('quit'\
                'set target'\
                'set var'\
                'set method'\
                'attack var'\
                'show'\
                'run'\
                'unset'\
                'help'\
                'history')
    OIFIS=$IFS
    IFS=$(echo -e '\n')
    while read command
    do
       history -s "${command}"
    done < ${fHistory}
    IFIS=$OIFIS

    compgen -W "${sComandos[@]}" _sComandos

    while [ 1 ]
    do
        read -e -p ">>> " line
        __invoque_hub "${line}"

        [ ! -z "${line}" ] && {
            history -s "${line}"
            echo "${line}" >> "${fHistory}"
        }
    done
}

# remove cookie
[ -e "${sCookie}" ] &&
    rm ${sCookie}

