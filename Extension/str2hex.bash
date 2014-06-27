str2hex()
{
	case "$1" in
		"-s") 
			echo -n "$2" | hexdump -ve '/1 "%02x"' | sed 's/^/0x/' 
			echo
			;;
		"-x")
			echo -n "$2" | hexdump -ve '/1 "%02x"' | sed 's/../\\x&/g'
			echo
			;;
		"-0x")
			echo -n "$2" | hexdump -ve '/1 "0x%02x "' | sed 's/\(.*\) /\1/'
			echo
			;;
		"-c")
			echo -n '{'
			echo -n "$2" | hexdump -ve '/1 "0x%02x, "' | sed 's/\(.*\), /\1/'
			echo '}'
			;;
        "-h")
            echo -e "${USAGE}"
            ;;
        *)
			echo -n "$1" | hexdump -ve '/1 "%02x "' | sed 's/\(.*\) /\1/'
			echo
			;;
	esac
}
