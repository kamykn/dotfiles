# vimの設定
## NeoBundleをまずはインストール
```
$ mkdir -p ~/.vim/bundle
$ git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
```

## その他のプラグインをインストール
```
$ ln -s ~/.vimrc ~/dotfiles/.vimrc
```
その後Vimを実行して、各種プラグインがインストールされるのを待つ。

## インデントプラグインとステータスバープラグインの色について
256色表示設定しないと、表現色が少なく、キレイに表示されない。

### iTerm
preferences->Profiles->Terminal->Report Terminal Typeをxterm-256colorに

### tmux
.tmux.confをdotfileのものと置き換える
```
$ ln -s ~/.tmux.conf ~/dotfiles/.tmux.conf
```


# tmuxをsshログインデフォルト実行
.bashrcを置き換え
```
$ mv ~/.bashrc ~/.bashrc.orig
$ ln -s ~/.bashrc ~/dotfiles/.bashrc
```

ただし、デフォルトでなにかといじられている場合もあるので、中身を見て、下記を移すだけでも良い
tmuxの起動時に$TERM変数がscreenになることを利用したスクリプト
```
# デフォルトでtmux起動
if command -v tmux>/dev/null; then
	[[ ! $TERM =~ screen ]] && [ -z $TMUX ] && exec tmux
fi
```


# Gitの設定
## Gitのdiffをvimdiffで見る
.gitconfigをdotfileのものと置き換えると利用可能
```
$ ln -s ~/.gitconfig ~/dotfiles/.gitconfig
```

または下記のコマンドをコピペ
```
$ git config --global diff.tool vimdiff
$ git config --global difftool.prompt false
$ git config --global merge.tool vimdiff
$ git config --global mergetool.prompt false
```

# Gitにコミットする用意
```
git remote add origin git@github.com:kmszk/dotfiles.git
```
