# sshログインをこのサーバーのキーを使うようにするための設定
# ansibleで使うため
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa

# 毎回screenを自動的に立ち上げる
if [[ $TERM != "screen" ]] exec screen -D -RR

