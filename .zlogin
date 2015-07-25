# sshログインをこのサーバーのキーを使うようにするための設定
# ansibleで使うため
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa

