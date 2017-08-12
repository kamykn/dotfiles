##====================================================##
##======= login and background color settings ========##
##====================================================##

function sv() {
	echo "select (d)ev, (p)rod, (v)agrant (l)og or (q)uit"

	IS_CHANCELED=0

	read input
	case "$input" in
		"dev" | "d" )
			TERM_BG_COLOR='green'
			TO_SSH_HOST='dev'
			;;
		"prod" | "p" )
			TERM_BG_COLOR='red'
			TO_SSH_HOST='dev'
			;;
		"log" | "l" )
			TERM_BG_COLOR='blue'
			TO_SSH_HOST='dev'
			;;
		"vagrant" | "v" )
			TERM_BG_COLOR='black'
			TO_SSH_HOST='vagrant'
			;;
		"quit" | "q" )
			TERM_BG_COLOR='black'
			IS_CHANCELED=1
			echo "Canceled"
			;;
		* )
			chsv
			;;
	esac

	osascript -e 'tell application "Terminal" to set current settings of first window to settings set "'$TERM_BG_COLOR'"'

	if [ $IS_CHANCELED -eq 1 ]; then
		return
	fi

	ssh $TO_SSH_HOST
}

