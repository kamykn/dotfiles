# sshログインをこのサーバーのキーを使うようにするための設定
# ansibleで使うため
# eval `ssh-agent -s`
# ssh-add ~/.ssh/id_rsa

# tmux 自動起動
if [ -z $TMUX ] ; then
	if [ -z `tmux ls` ] ; then
		tmux
	else
		tmux attach
	fi
fi
