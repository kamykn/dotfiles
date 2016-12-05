# .zshrc をコンパイルして .zshrc.zwc を生成するコマンド
zcompile .zshrc

##========================================================##
##================== キーバインドの設定 ==================##
##========================================================##
bindkey -e      # emacs キーバインド

##========================================================##
##================= リストの色つけの設定 =================##
##========================================================##
alias ll='ls -l'
alias ls='ls --color'

##========================================================##
##=================== プロンプトの設定 ===================##
##========================================================##
autoload -U promptinit ; promptinit
autoload -U colors     ; colors
# プロンプトテーマを表示するコマンド
# prompt -l
# 基本のプロンプト
PROMPT="%{$reset_color%}$ "
# [場所] プロンプト
PROMPT="%{$reset_color%}[%{$fg[red]%}%B%~%b%{$reset_color%}]$PROMPT"
# 名前@マシン名 プロンプト
PROMPT="%{$reset_color%}%{$fg[green]%}$USER%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%}$PROMPT"
RPROMPT="%{$fg[green]%}[%*]%{$reset_color%}"

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
