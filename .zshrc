# .zshrc をコンパイルして .zshrc.zwc を生成するコマンド
zcompile .zshrc


##========================================================##
##=============== コマンド入力キーバインド ===============##
##========================================================##

bindkey -v      # vi キーバインド
bindkey "^[[5C" forward-word # Ctrl+右矢印キー（→）で右に１単語移動
bindkey "^f" forward-word # Ctrl+f で右に１単語移動
bindkey "^[[5D" backward-word # Ctrl+左矢印キー（←）で左に１単語移動
bindkey "^b" backward-word # Ctrl+b で左に１単語移動


##========================================================##
##================= リストの色つけの設定 =================##
##========================================================##

# ls, #dir, vdir の設定
alias s='screen -U'
alias ll='ls -l'
alias ls='ls --color'
alias grep='grep --color=auto'
export MAILCHECK=0
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
# 補完候補にも色付き表示
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# kill の候補にも色付き表示
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'


##========================================================##
##====================== 補完の設定 ======================##
##========================================================##

autoload -U compinit ; compinit
# 補完候補の大文字小文字の違いを無視
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1 # 補完候補を←↓↑→で選択
zstyle ':completion:*' use-cache true        # 補完キャッシュ


##========================================================##
##==================== 予測補完の設定 ====================##
##========================================================##

autoload -U predict-on       # 履歴による予測入力 (man zshcontrib)
zle -N predict-on
zle -N predict-off
bindkey '^xp'  predict-on    # Cttl+x p で予測オン
bindkey '^x^p' predict-off   # Cttl+x Ctrl+p で予測オフ


##========================================================##
##====================== 履歴の設定 ======================##
##========================================================##
HISTFILE=$HOME/.zsh_history  # 履歴をファイルに保存する
HISTSIZE=10000              # メモリ内の履歴の数
SAVEHIST=10000              # 保存される履歴の数
setopt extended_history      # 履歴ファイルに開始時刻と経過時間を記録
#unsetopt extended_history
setopt append_history        # 履歴を追加 (毎回 .zhistory を作るのではなく)
setopt inc_append_history    # 履歴をインクリメンタルに追加
setopt share_history         # 履歴の共有
setopt hist_ignore_all_dups  # 重複するコマンド行は古い方を削除
setopt hist_ignore_dups      # 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_space     # スペースで始まるコマンド行はヒストリリストから削除
# (→ 先頭にスペースを入れておけば、ヒストリに保存されない)
unsetopt hist_verify         # ヒストリを呼び出してから実行する間に一旦編集可能を止める
setopt hist_reduce_blanks    # 余分な空白は詰めて記録
setopt hist_save_no_dups     # ヒストリファイルに書き出すときに、古いコマンドと同じものは無視する。
setopt hist_no_store         # historyコマンドは履歴に登録しない
setopt hist_expand           # 補完時にヒストリを自動的に展開

# コマンド履歴検索
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

