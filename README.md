# vlyulin_microservices
vlyulin microservices repository

#Content:
* [Student](#Student)
* [Module hw12-docker-2](#Module-hw12-docker-2)

# Student
`
Student: Vadim Lyulin
Course: DevOps
Group: Otus-DevOps-2021-08
`

## Module hw12-docker-2" Запуск VM с установленным Docker Engine при помощи Docker Machine. Написание Dockerfile и сборка образа с тестовым приложением. Сохранение образа на DockerHub. <a name="Module-hw12-docker-2"></a>
> Цель: В данном дз студент продолжит работать с Docker, создаст образы приложения и загрузит из в DockerHub.
> В данном задании тренируются навыки: работы с Docker, DockerHub.

1. Создана ветка docker-2
2. Создана директория dockermonolith
3. Установлен Docker и проверен с помощью контейнера hello-world
4. Установлен и настроен Yandex Cloud CLI
5. Установлен docker-machine
https://github.com/docker/machine/releases
```
$ curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
    chmod +x /tmp/docker-machine &&
    sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
```
6. Создан Docker хост в Yandex Cloud
```
yc compute instance create \
  --name docker-host \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/id_rsa.pub

docker-machine create \
  --driver generic \
  --generic-ip-address=<ПУБЛИЧНЫЙ_IP_СОЗДАНОГО_ВЫШЕ_ИНСТАНСА> \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/id_rsa \
  docker-host
  
eval $(docker-machine env docker-host)
```
7. Проверка, что docker-host успешно создан
```
docker-machine ls
```
вывод
```
NAME          ACTIVE   DRIVER    STATE     URL                        SWARM   DOCKER      ERRORS
docker-host   *        generic   Running   tcp://51.250.13.185:2376           v20.10.11
```

8. PID namespace (изоляция процессов)

Сравнение запуска docker с и без совместного использования process namespace для host машины.
Команда:
```
docker run --rm -ti tehbilly/htop
```
![](img/without-pid-host.png)
Команда:
```
docker run --rm --pid host -ti tehbilly/htop
```
![](img/with-pid-host.png)

Вывод: при использованиии параметра --pid host для контейнера становятся видны все процессы host-машины.

9. net namespace (изоляция сети)
```
--network=host
```
If you use the host network mode for a container, that container’s network stack is not isolated from the Docker host 
(the container shares the host’s networking namespace), and the container does not get its own IP-address allocated. 
For instance, if you run a container which binds to port 80 and you use host networking, the container’s application 
is available on port 80 on the host’s IP address.

10. user namespaces (изоляция пользователей)
```
--userns=host
```
To disable user namespaces for a specific container, add the --userns=host flag to the docker container create, 
docker container run, or docker container exec command.
https://docs.docker.com/engine/security/userns-remap/

11. Созданы файлы db_config Dockerfile mongod.conf start.sh 
12. Собран image reddit
```
docker build -t reddit:latest .
```
13. Запущен контейнер
```
docker run --name reddit -d --network=host reddit:latest
```
14. Проверка результата
```
docker-machine ls
```
вывод:
```
NAME          ACTIVE   DRIVER    STATE     URL                        SWARM   DOCKER      ERRORS
docker-host   *        generic   Running   tcp://51.250.13.185:2376           v20.10.11
```

15. Выполнена регистрация на Docker hub
16. Выполнена аутентификация на Docker Hub
```
docker login
```
вывод
```
Login Succeeded
```

17. Загружен образ reddit на docker hub
```
docker tag reddit:latest vlyulin/otus-reddit:1.0
docker push vlyulin/otus-reddit:1.0 
```
18. Проверен запуск загруженного в Docker hub образа в локальном docker
```
docker run --name reddit -d -p 9292:9292 vlyulin/otus-reddit:1.0
```
19. Просмотр логов контейнера
```
docker logs reddit -f
```
20. Команда интерактивного запуска bash в контейнере
```
docker exec -it reddit bash
```
вывод
```
root@docker-host:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  18032  2772 ?        Ss   18:59   0:00 /bin/bash /start.sh
root        10  0.3  1.7 391396 36640 ?        Sl   18:59   0:13 /usr/bin/mongod --fork --logpath /var/log/mongod.log --
root        21  0.0  1.5 650992 31500 ?        Sl   19:00   0:01 puma 3.10.0 (tcp://0.0.0.0:9292) [reddit]
root        36  0.4  0.1  18244  3224 pts/0    Ss   19:56   0:00 bash
root        51  0.0  0.1  34424  2820 pts/0    R+   19:56   0:00 ps aux
root@docker-host:/#
```
21. Выполнены проверки:
```
docker logs reddit -f
```

```
docker exec -it reddit bash
```


```
docker run --name reddit --rm -it vlyulin/otus-reddit:1.0 bash
ps aux
```
вывод:
```
root@691a1a36b0f9:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.3  0.1  18244  3108 pts/0    Ss   11:25   0:00 bash
root        17  0.0  0.1  34424  2868 pts/0    R+   11:25   0:00 ps aux
root@691a1a36b0f9:/# exit
exit
```

С  помощью  следующих  команд  можно  посмотреть  подробную
информацию  о  образе,  вывести  только  определенный  фрагмент
информации, запустить приложение и добавить/удалить папки и осмотреть
дифф,  проверить  что  после  остановки  и  удаления  контейнера  никаких
изменений не останется:

```
docker inspect vlyulin/otus-reddit:1.0
```
вывод:
```
[
    {
        "Id": "sha256:bf6e64c49aa3c1ff131dc8cc9033f2466d07204388dd2d984629e7b6ae0631ad",
        "RepoTags": [
            "reddit:latest",
            "vlyulin/otus-reddit:1.0"
        ],
        "RepoDigests": [
            "vlyulin/otus-reddit@sha256:caeb05eaac980c7d9a426610507c01468fb2fb1f5bf82d6199d2a7e87b0fbd1d"
        ],
        "Parent": "sha256:52f3a1b5646961d169e540eebbff63e0984fe1ed6f986fc7d60eec6af8888e2e", ...
```

```
docker inspect vlyulin/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}'
```
вывод:
```
[/bin/sh -c #(nop)  CMD ["/start.sh"]]
```

```
docker run --name reddit -d -p 9292:9292 vlyulin/otus-reddit:1.0
```
вывод:
```
ae2629db5090a652e04ea819b5238e9c9dfbdf6a24584359e2377d25e9b1fa47
```

```
docker exec -it reddit bash
mkdir /test1234
touch /test1234/testfile
rmdir /opt
docker diff reddit
```
>**_Note_**: docker diff: List the changed files and directories in a containers filesystem since the container was created.

вывод:
```
A /test1234
A /test1234/testfile
C /tmp
A /tmp/mongodb-27017.sock
C /var
C /var/log
A /var/log/mongod.log
C /var/lib
C /var/lib/mongodb
A /var/lib/mongodb/mongod.lock
A /var/lib/mongodb/_tmp
A /var/lib/mongodb/journal
A /var/lib/mongodb/journal/j._0
A /var/lib/mongodb/journal/prealloc.1
A /var/lib/mongodb/journal/prealloc.2
A /var/lib/mongodb/local.0
A /var/lib/mongodb/local.ns
C /root
A /root/.bash_history
D /opt
```

```
docker stop reddit && docker rm reddit
docker run --name reddit --rm -it vlyulin/otus-reddit:1.0 bash
ls /
```
вывод
```
bin   dev  home  lib64  mnt  proc    root  sbin  start.sh  tmp  var
boot  etc  lib   media  opt  reddit  run   srv   sys       usr
```
>**_Note_**: директория opt на месте

### Задание со *
>>>
Когда  есть  готовый  образ  с  приложением,  можно
автоматизировать  поднятие  нескольких  инстансов  в  Yandex  Cloud,
установку на них докера и запуск там образа /otus-reddit:1.0
- Нужно реализовать в виде прототипа в директории /docker-monolith/infra/
- Поднятие инстансов с помощью Terraform, их количество задается переменной;
- Несколько плейбуков Ansible с использованием динамического инвентори для установки докера и запуска там образа приложения;
- Шаблон пакера, который делает образ с уже установленным Docker;
>>>

1. Создана директория docker-monolith\infra\packer 
2. Настроен inventory
Проверена работоспособность yacloud_compute inventory plugin
>**_Note_**: команды выполняются из директории ansible
```
ansible -i environments/stage/yacloud_compute.yml --playbook-dir=./playbooks --list-hosts all
после настройки ansible.cfg
ansible --list-hosts all
```
вывод:
```
  hosts (1):
    docker-host
```
3. Созданы директории ./docker-monolith/infra/packer и ./docker-monolith/infra/ansible
4. Созданы соответствующие файла сборки image в директории /packer. 
Создан файл docker-monolith\infra\ansible\playbooks\install_docker.yml для установки docker в image создаваемый packer.
В файле packer/ubuntu-with-docker.json указано использование install_docker.yml
```
    "provisioners": [
        {
            "type": "ansible",
            "playbook_file": "ansible/playbooks/install_docker.yml"
        }
```
5. Проверен и создан образ
```
packer validate -var-file=./packer/variables.json ./packer/ubuntu-with-docker.json
packer build -var-file=./packer/variables.json ./packer/ubuntu-with-docker.json
```
вывод
```
Build 'yandex' finished after 3 minutes 56 seconds.

==> Wait completed after 3 minutes 56 seconds

==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: ubuntu-with-docker-1637950974 (id: fd87c49pj8rv80utnbd3) with family name ubuntu-with-docker
```

![](img/ubuntu-with-docker-image.png)

6. Создана директория ./docker-monolith/infra/terraform. 
В файле Main.tf указан созданный packer образ через переменную var.disk_image
```
  boot_disk {
    initialize_params {
      image_id = var.disk_image
    }
  }
```

7. Проинициализирован terraform в дирректории ./terraform
```
init terraform
```
вывод:
```
Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "yandex" (terraform-providers/yandex) 0.56.0...
```

8. Выполнена проверка настроек terraform. Исполняется из директории ./terraform
```
terraform plan
```
вывод
```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.docker[0] will be created
  + resource "yandex_compute_instance" "docker" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + labels                    = {
          + "tags" = "docker"
        }
...
```

9. Созданы окружения
```
terraform apply
```
вывод
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

internal_ip_address_app = [
  "10.128.0.16",
  "10.128.0.13",
]
```

10. Создан файл docker-monolith\infra\ansible\playbooks\install-reddit.yml для установки приложения reddit

11. Выполнена установка приложения reddit как контейнеры на окружения в docker.
Выполняется из директории ./infra/ansible
Проверка группы окружений docker.
```
ansible --list-hosts docker
```
вывод
```
  hosts (2):
    docker-1
    docker-0
```
установка
```
ansible-playbook ./playbooks/install-reddit.yml --limit docker
```
12. Проверка работоспособности приложения
http://<public ip>:9292


sudo wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v1.16.3/hadolint-Linux-x86_64
sudo chmod +x /bin/hadolint