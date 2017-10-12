# .zshrc をコンパイルして .zshrc.zwc を生成するコマンド
zcompile .zshrc

export LANG=ja_JP.UTF-8

##========================================================##
##================== キーバインドの設定 ==================##
##========================================================##
bindkey -e      # emacs キーバインド

##========================================================##
##================= リストの色つけの設定 =================##
##========================================================##
alias ll='ls -l'
# alias ls='ls --color' # linux
alias ls='ls -G' # Unix

##========================================================##
##=================== プロンプトの設定 ===================##
##========================================================##
autoload -U promptinit ; promptinit
autoload -U colors     ; colors

# プロンプトテーマを表示するコマンド
# prompt -l

# 名前@マシン名 プロンプト
# PROMPT="%{$reset_color%}%{$fg[green]%}$USER%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%} "
PROMPT="$USER@%m "

# [場所] プロンプト
PROMPT+="%{$reset_color%}%{$fg[cyan]%}%B%~%b%{$reset_color%} "

# 右部分 [時間]
# RPROMPT="%{$fg[green]%}[%*]%{$reset_color%}"

##====================================================##
##========================= Git ======================##
##====================================================##

# vcs_infoロード
autoload -Uz vcs_info
# PROMPT変数内で変数参照する
setopt prompt_subst

# vcsの表示
zstyle ':vcs_info:*' formats '%s][* %F{green}%b%f'
zstyle ':vcs_info:*' actionformats '%s][* %F{green}%b%f(%F{red}%a%f)'

# プロンプト表示直前にvcs_info呼び出し
precmd() {
	vcs_info
}

# vcs_info_msg_0_の書式設定
# zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' check-for-changes false
zstyle ':vcs_info:git:*' stagedstr         "%F{yellow}!%f"
zstyle ':vcs_info:git:*' unstagedstr       "%F{red}+%f"
zstyle ':vcs_info:*'     formats           "(%F{green}%b%f%c%u) "
zstyle ':vcs_info:*'     actionformats     '(%b|%a) '

# プロンプト表示
PROMPT+='${vcs_info_msg_0_}'

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
	fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
	git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

##========================================================##
##====================== 補完の設定 ======================##
##========================================================##

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

##========================================================##
##====================== 履歴の設定 ======================##
##========================================================##
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

##========================================================##
##====================== 雑多な設定 ======================##
##========================================================##
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

##====================================================##
##===================StatusBar Plugin=================##
##====================================================##

export TERM=xterm-256color


##====================================================##
##==================== enable z cmd ==================##
##====================================================##
. /usr/local/etc/profile.d/z.sh

##====================================================##
##========================= FZF ======================##
##====================================================##

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

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
	local DIR=$(get_parent_dirs "${1:-$PWD}" | fzf-tmux --tac)
	cd "$DIR"
}

ffind() {
	local FIND_OPTION=''

	# 第一引数だけ見て-aかどうか評価するので注意
	if [ "${1}" != "-a" ]; then
		FIND_OPTION=" -type d -name '.*' -prune -or -not -name '.*'"
	fi

	eval find . "*" "${FIND_OPTION}" | fzf
}

# git commit browser
fcommitshow() {
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
fcommitsearch() {
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
		fzf-tmux --multi --exit-0 --expect=ctrl-d); do
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

##====================================================##
##================== 画像プレビュー ==================##
##====================================================##

# macのみ
alias ql='qlmanage -p "$@" >& /dev/null'

##====================================================##
##================= gitをbrew優先に ==================##
##====================================================##

PATH="/usr/local/bin:${PATH}"

##====================================================##
##====================== cargo =======================##
##====================================================##

PATH="${PATH}:$HOME/.cargo/bin"


export PATH
