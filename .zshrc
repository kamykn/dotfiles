# vim: foldmethod=marker
# vim: foldcolumn=3
# vim: foldlevel=0

#     ___       ___       ___       ___       ___
#    /\__\     /\__\     /\  \     /\  \     /\__\
#   /:/ _/_   /::L_L_   /::\  \   _\:\  \   /:/ _/_
#  /::-"\__\ /:/L:\__\ /\:\:\__\ /::::\__\ /::-"\__\
#  \;:;-",-" \/_/:/  / \:\:\/__/ \::;;/__/ \;:;-",-"
#   |:|  |     /:/  /   \::/  /   \:\__\    |:|  |
#    \|__|     \/__/     \/__/     \/__/     \|__|
#

# {{{
# .zshrc をコンパイルして .zshrc.zwc を生成するコマンド
zcompile ~/.zshrc

export LANG=ja_JP.UTF-8

alias vi='vim'
alias vimupdate='brew upgrade vim --with-lua --with-python3'
#}}}

##========================================================##
##================== キーバインドの設定 ==================##
##========================================================##
bindkey -e      # emacs キーバインド

##========================================================##
##================= リストの色つけの設定 =================##
##========================================================##
# {{{
alias ll='ls -l'
# alias ls='ls --color' # linux
alias ls='ls -G' # Unix
# }}}

##========================================================##
##=================== プロンプトの設定 ===================##
##========================================================##

# {{{

# オススメ背景色
# C: 84
# M: 76
# Y: 47
# K: 50

autoload -U promptinit ; promptinit
autoload -U colors     ; colors

# プロンプトテーマを表示するコマンド
# prompt -l

# 名前@マシン名 プロンプト
# 参考 https://github.com/sindresorhus/pure/blob/master/readme.md
# 背景 HSB: 色相232°彩度30% 明度19%
local prompt_location="%F{081}%B%~%b%f"
local promot_mark="%B%F{208}%(!,#,λ) %f%b"
local status_code="%(?,,%F{208} 》 %f%B%F{red}%?%f%b)"
local number_of_jobs="%(1j.%F{208} 》 %f%F{226}%B%j%b%f.)"


# 右部分 [時間]
# RPROMPT="%{$fg[green]%}[%*]%{$reset_color%}"

# }}}

##====================================================##
##========================= Git ======================##
##====================================================##

# {{{
# vcs_infoロード
autoload -Uz vcs_info
# PROMPT変数内で変数参照する
setopt prompt_subst

# vcsの表示
# プロンプト表示直前にvcs_info呼び出し
precmd() {
	vcs_info
}

# vcs_info_msg_0_の書式設定
# zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' check-for-changes false
zstyle ':vcs_info:git:*' stagedstr         "%F{yellow}!%f"
zstyle ':vcs_info:git:*' unstagedstr       "%F{red}+%f"
zstyle ':vcs_info:*'     formats           "%F{208} 》%f%F{113}%b%c%u%f"
zstyle ':vcs_info:*'     actionformats     ' (%b|%a)'

# プロンプト
PROMPT="
${prompt_location}%B"'$vcs_info_msg_0_'"%b${number_of_jobs}${status_code}
${promot_mark}"

# fzfでブランチ名絞込チェックアウト
# ローカルブランチ
fbr() {
	local branches branch
	branches=$(git branch) &&
	branch=$(echo "$branches" | fzf +s +m) &&
	git checkout $(echo "$branch" | sed "s/.* //")
}


# リモートブランチ
fbrm() {
	local branches branch
	branches=$(git branch --all | grep -v HEAD) &&
	branch=$(echo "$branches" |
	fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
	git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}


# ローカルブランチ名コピー
fbranchcp() {
	local branches branch
	branches=$(git branch) &&
	branch=$(echo "$branches" | fzf +s +m) &&
	echo $(echo "$branch" | sed "s/.* //" ) | tr -d "\n" '' | pbcopy; pbpaste ; echo '';
}

# ブランチ名を出力
alias brname='git symbolic-ref --short HEAD'
alias cpbrname='git symbolic-ref --short HEAD  | tr -d "\n" '' | pbcopy'

alias gitroot='git rev-parse --show-toplevel'
alias cdgitroot='cd `git rev-parse --show-toplevel`'
# }}}

##========================================================##
##====================== 補完の設定 ======================##
##========================================================##
# {{{
# gitコマンド補完
# http://blog.qnyp.com/2013/05/14/zsh-git-completion/

# 補完スクリプト配置先
fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
fpath=(~/.zsh/.zsh-completions $fpath)

# 補完設定
autoload -U compinit
compinit -u
# 補完対象
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                             /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin \
                             /usr/local/git/bin

zstyle ':completion:*:default' menu select=1

# LS_COLORSを設定しておく
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# ファイル補完候補に色を付ける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
#}}}

##========================================================##
##====================== 履歴の設定 ======================##
##========================================================##
# {{{
HISTFILE=$HOME/.zsh_history   # 履歴をファイルに保存する
HISTSIZE=100000               # メモリ内の履歴の数
SAVEHIST=100000               # 保存される履歴の数
setopt extended_history       # 履歴ファイルに開始時刻と経過時間を記録
#unsetopt extended_history
setopt append_history         # 履歴を追加 (毎回 .zhistory を作るのではなく)
setopt inc_append_history     # 履歴をインクリメンタルに追加
setopt share_history          # 履歴の共有
setopt hist_ignore_all_dups   # 重複するコマンド行は古い方を削除
setopt hist_ignore_dups       # 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_space      # スペースで始まるコマンド行はヒストリリストから削除
                              # (→ 先頭にスペースを入れておけば、ヒストリに保存されない)
unsetopt hist_verify          # ヒストリを呼び出してから実行する間に一旦編集可能を止める
setopt hist_reduce_blanks     # 余分な空白は詰めて記録
setopt hist_save_no_dups      # ヒストリファイルに書き出すときに、古いコマンドと同じものは無視する。
setopt hist_no_store          # historyコマンドは履歴に登録しない
setopt hist_expand            # 補完時にヒストリを自動的に展開

# コマンド履歴検索
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
# }}}

##========================================================##
##====================== 雑多な設定 ======================##
##========================================================##
# {{{
setopt no_beep                # コマンド入力エラーでBeepを鳴らさない
setopt numeric_glob_sort      # 数字を数値と解釈してソートする
setopt path_dirs              # コマンド名に / が含まれているとき PATH 中のサブディレクトリを探す
setopt print_eight_bit        # 補完候補リストの日本語を適正表示

unsetopt flow_control         # (shell editor 内で) C-s, C-q を無効にする
setopt no_flow_control        # C-s/C-q によるフロー制御を使わない
setopt notify                 # バックグラウンドジョブが終了したら(プロンプトの表示を待たずに)すぐに知らせる
setopt always_last_prompt     # カーソル位置は保持したままファイル名一覧を順次その場で表示

setopt rm_star_wait           # rm * を実行する前に確認

export PATH=~/local/bin:$PATH # ローカルのパスを優先する
# }}}

##====================================================##
##===================StatusBar Plugin=================##
##====================================================##

export TERM=xterm-256color

##====================================================##
##========================= FZF ======================##
##====================================================##

# {{{

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS='--height 40% --reverse'

# 下層cd
fcd() {
	local dir
	dir=$(find ${1:-.} -path '*/\.*' -prune \
		-o -type d -print 2> /dev/null | fzf +m) &&
	cd "$dir"
}

# 上層cd
fcdr() {
	local declare dirs=()
	get_parent_dirs() {
		if [[ -d "${1}" ]]; then dirs+=("$1"); else return; fi
		if [[ "${1}" == '/' ]]; then
			for _dir in "${dirs[@]}"; do echo $_dir; done
		else
			get_parent_dirs $(dirname "$1")
		fi
	}
	# local DIR=$(get_parent_dirs $(realpath "${1:-$PWD}") | fzf-tmux --tac)
	local DIR=$(get_parent_dirs "${1:-$PWD}" | fzf --tac)
	cd "$DIR"
}

ffind() {
	local FIND_OPTION=''

	# 第一引数だけ見て-aかどうか評価するので注意
	if [ "${1}" != "-a" ]; then
		FIND_OPTION=" -type d -name '.*' -prune -or -not -name '.*'"
	fi

	eval find . "*" "${FIND_OPTION}" | fzf --multi
}

# git commit browser
fglogg() {
	git log --graph --color=always \
		--format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
	fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
		--bind "ctrl-m:execute:
			(grep -o '[a-f0-9]\{7\}' | head -1 |
			xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
			{}
FZF-EOF"
}

# commit hash search
fglog() {
	local commits commit
	commits=$(git log --color=always --pretty=oneline --abbrev-commit --reverse) &&
		commit=$(echo "$commits" | fzf --tac +s +m -e --ansi --reverse) &&
		echo -n $(echo "$commit" | sed "s/ .*//")
}

# https://qiita.com/reviry/items/e798da034955c2af84c5
fadd() {
	local out q n addfiles
	while out=$(
		git status --short |
		awk '{if (substr($0,2,1) !~ / /) print $2}' |
		fzf --multi --exit-0 --expect=ctrl-d); do
			q=$(head -1 <<< "$out")
			n=$[$(wc -l <<< "$out") - 1]
			addfiles=(`echo $(tail "-$n" <<< "$out")`)
			[[ -z "$addfiles" ]] && continue
			if [ "$q" = ctrl-d ]; then
				git diff --color=always $addfiles | less -R
			else
				git add $addfiles
			fi
		done
}

# worktree移動
cdworktree() {
	# カレントディレクトリがGitリポジトリ上かどうか
	# git status &>/dev/null # 重い場合がある？
	git rev-parse &>/dev/null
	if [ $? -ne 0 ]; then
		echo fatal: Not a git repository.
		return 1
	fi

	local selectedWorkTreeDir=`git worktree list | fzf | awk '{print $1}'`

	if [ "$selectedWorkTreeDir" = "" ]; then
		# Ctrl-C.
		return 1
	fi

	cd ${selectedWorkTreeDir}
}

# worktree移動
cdrepo() {
	local selectedRepo=`ghq list -p | fzf`

	if [ "$selectedRepo" = "" ]; then
		# Ctrl-C.
		return 1
	fi

	cd ${selectedRepo}
}

fzf-z-search() {
	local res=$(z | sort -rn | cut -c 12- | fzf)
	if [ -n "$res" ]; then
		BUFFER+="cd $res"
		zle accept-line
	else
		return 1
	fi
}

zle -N fzf-z-search
bindkey '^f' fzf-z-search

# }}}

##====================================================##
##======================= zplug ======================##
##====================================================##
# {{{
#
# brew install zplug
# In order to use zplug, please add the following to your .zshrc:
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# ---------------------------------------------------
zplug "zsh-users/zsh-completions"
# ---------------------------------------------------

# ---------------------------------------------------
zplug "zsh-users/zsh-syntax-highlighting", defer:2
# ---------------------------------------------------
# Set the priority when loading
# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
# (If the defer tag is given 2 or above, run after compinit command)

# ---------------------------------------------------
zplug "zsh-users/zsh-autosuggestions", defer:2
# ---------------------------------------------------
# ---------------------------------------------------
zplug "supercrabtree/k"
# ---------------------------------------------------
# ---------------------------------------------------
zplug "rupa/z", use:z.sh
# ---------------------------------------------------
# ---------------------------------------------------
zplug "motemen/ghq", as:command, from:gh-r, rename-to:ghq
# ---------------------------------------------------

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load

# }}}

##====================================================##
##=============== 覚えられない系 alias ===============##
##====================================================##

# {{{
##====================================================##
##================== 画像プレビュー ==================##
##====================================================##

# macのみ
alias ql='qlmanage -p "$@" >& /dev/null'

##====================================================##
##============ sql結果をcsvにコピペできる ============##
##====================================================##

alias qr2cp="pbpaste | sed '/+--/d' | sed -e 's/|//' | sed -e 's/|\$//' | sed -e '2,$ s/ //g' | tr '|' '\t'| pbcopy"

##====================================================##
##==================== 集計系便利 ====================##
##====================================================##

# https://orebibou.com/2016/03/linuxunix%E3%81%AE%E3%82%B3%E3%83%B3%E3%82%BD%E3%83%BC%E3%83%AB%E3%81%A7%E5%B9%B3%E5%9D%87%E3%83%BB%E4%B8%AD%E5%A4%AE%E5%80%A4%E3%83%BB%E6%9C%80%E5%A4%A7%E3%83%BB%E6%9C%80%E5%B0%8F%E3%82%92%E6%B1%82/
# 数値をリストで渡す

# 平均
alias avg='awk "{x++;sum+=$1}END {print sum/x}"'
# 中央値
alias median='sort -n | awk "{v[i++]=$1;}END {x=int((i+1)/2); if(x<(i+1)/2) print (v[x-1]+v[x])/2; else print v[x-1];}"'

# }}}

##====================================================##
##==================== $PATHなど =====================##
##====================================================##

# {{{

##====================================================##
##================= gitをbrew優先に ==================##
##====================================================##

PATH="/usr/local/bin:${PATH}"

##====================================================##
##====================== cargo =======================##
##====================================================##
# for rust

PATH="${PATH}:$HOME/.cargo/bin"

# }}}

##====================================================##
##=================== 無駄なもの =====================##
##====================================================##

# {{{

command_not_found_handler(){
	echo -e		"\n\e[1;33m                 >>> $0 <<<"
	echo -e 	"\e[1;31m                        __            __ \n" \
				".--.--.--.---.-.-----.|  |_.-----.--|  |\n" \
				"|  |  |  |  _  |__ --||   _|  -__|  _  |\n" \
				"|________|___._|_____||____|_____|_____|\n"
}

# }}}

export PATH
