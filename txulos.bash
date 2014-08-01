#!/bin/bash

Version="0.0.1"
# control variable
sOperationMode=""
iLineCount=""
cWGET=$(which wget)
#
sUrl=""
sOptions=""
fHistory=~/.txulos
fFileName="$1"
sTarget=""
sVariable=""
sMethod="${sMethod:-GET}"
sCookie="$(mktemp)"
sUserAgent="(TXulos/0.0.1)"
sWgetOptions=""
sFilter="tee"
sDataType=""

# temporari script
fTmpScript=$(mktemp)


# load extension
#[ ! -z "${TXULOS_EXTENSION}" -a \
#    -d "${TXULOS_EXTENSION}" ] &&
#    for file in $( ls -1 ${TXULOS_EXTENSION}/ )
#    do
#        source ${TXULOS_EXTENSION}/${file}
#    done

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
            datatype)
                [ "${sString^^}" == 'JSON' ]
                sDataType="${sString}"
                sWgetOptions="${sWgetOptions} --header 'Content-Type: application/json' -S"
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
    sOptions="--cookie=on --save-cookies=${sCookie} --load-cookies=${sCookie} --keep-session-cookies"

    [ ! -z "${sUserAgent}" ] &&
        sOptions="${sOptions} --user-agent='"${sUserAgent}"' "
    [ ! -z "${sWgetOptions}" ] &&
        sOptions="${sOptions} ${sWgetOptions}"

    case ${sMethod^^} in
        POST)
            [ "${sVariable:0:1}" != '&' -a \
                "${sVariable}" != '&'  -a \
                "${sDataType}" != 'JSON' ] && sVariable="&${sVariable}"
            [ "${sVariable:$((${#sVariable}-1)):${#sVariable}}" != "&" -a \
                "${sVariable}" != '&' -a \
                "${sDataType}" != 'JSON' ] && sVariable="${sVariable}&"

            sUrl="${sTarget}"

            [ "${sDataType}" == 'JSON' ] && {
                sVariable="$(echo "${sVariable}" | sed 's/"/\\"/g; s/,/\\,/g;')"
                echo "${cWGET} -q -O - --post-data "${sVariable}" ${sOptions} ${sUrl} " > ${fTmpScript}
            } || {

               echo "${cWGET} -q -O - --post-data='"${sVariable}"' ${sOptions} ${sUrl} " > ${fTmpScript}
            }
            ;;
        GET)
            [ "${sVariable:0:1}" != '?' ] && sVariable="?${sVariable}"
            sUrl="${sTarget}${sVariable}"
            sOptions="${sOptions}"
            echo "${cWGET} -q -O -  ${sOptions} ${sUrl}" > ${fTmpScript}
            ;;
    esac
}

__run()
{
    local WGETPARAM

    [ -z "${sTarget}" -o\
        -z "${sMethod}" ] && {
        echo "Headshot : target or method not set"
        return 1
    }

    __organizer
    #[ ${sOperationMode} == 1 ] &&
    #{
        chmod +x ${fTmpScript}
        ${fTmpScript} | ${sFilter}
    #} || {
    #    WGETPARAM=$(cat ${fTmpScript})
    #    ${WGETPARAM} | ${sFilter}
    #}
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
    echo "  Data Type  : ${sDataType}"
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
    local sAttackVar="$( echo $1 | sed 's/\]/\\]/; s/\[/\\[/')"
    local sVariablePreserver="${sVariable}"
    local sAttackString=""
    local sVarExistInVariable=""

    sVarExistInVariable=$(echo ${sVariable} |
                                    tr \& \\n |
                                    cut -d \= -f1 |
                                    grep  "^${sAttackVar}$" )

    echo "${sVarExistInVariable} - ${sAttackVar}"

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
        [ ${sOperationMode} -eq 0 ] && {
            echo "Headshot ${sHandler}"
            exit
        }
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
    echo " - import"
    echo "      > import source.sqi"
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
            __attack_var "${sParam}"
            __check_headshot "${sParam} ${sStore}"
            ;;
        QUIT)
            exit
            ;;
        IMPORT)
            while read line
            do
                __invoque_hub "${line}"
            done < "${sParam}"
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
                'import'\
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

# remove cookie and tmp script
[ -e "${sCookie}" ] &&
    rm ${sCookie} ${fTmpScript}

