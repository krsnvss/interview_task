# Тестовое задание для кандидата
В этом репозитории есть все, чтобы быстро развернуть и настроить виртуальную машину на базе VMWare Cloud Director для практического этапа собеседоввания.
## Terraform
Файл `interview.tf` позволит создать virtual application с виртуальной машиной и виртуальной сетью. Виртуальная машина на базе Flatcar Linux будет создана, преднастроена и запущена автоматически.
### Инcтрукция по применению
> Обратите внимание! Terraform state хранится локально, поэтому все операции лучше выполнять с одного и того же узла.

1. Установите переменные окружения VCD_USER (имя пользователя тестового org), VCD_PASSWORD (пароль пользователя тестового org), TF_VAR_ssh_key_file (путь к публичному ключу ssh), TF_VAR_user_pass (пароль пользователя **candidate**)
```shell
export VCD_USER='org_user' VCD_PASSWORD='VerySecurePassword' TF_VAR_ssh_key_file="$HOME/.ssh/id_rsa.pub" TF_VAR_user_pass="User'sPassword"
```
2. Выполните команду `terraform plan`, чтобы посмотреть какие изменения будут применяться
3. Примените конфигурацию
```shell
terraform apply -auto-approve
```
4. Подключитесь к созданной виртуальной машине (по умолчанию будет создан и добавлен в группу **sudo** пользователь **candidate**)
```shell
ssh candidate@1.2.3.4
```
5. Выполните скрипт, который установит docker compose и создаст контейнеры для тестового задания
```shell
cd /opt/web-srv
./prepare_host.sh
```
6. Убедитесь, что контейнеры запущены
```shell
docker ps
```
> дополнительно можно сменить пароль пользователя **candidate** с помощью утилиты `passwd`
7. По завершении тестового задания удалите vApp
```shell
terraform destroy -auto-approve
```

## Ansible
Плейбук `prepare_host.yml` позволяет преднастроить для выполнения тестового задания виртуальную машину на базе Ubuntu 20.04.
Пароль пользователя **candidate** можно указать через переменную `user_pass`
```shell
ansible-playbook -i inventory.yml prepare_host.yml -e "user_pass=MySecretPassword"
```
Плейбук создаст пользователя, установит docker, запустит 3 контейнера с nginx. 
Кроме того, плейбук содержит таски позволяющие создать контейнер с правильным ответом (тэг answer) и усложнить задачу (тэг hard_mode).

