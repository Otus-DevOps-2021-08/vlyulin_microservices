# vlyulin_microservices
vlyulin microservices repository

#Content:
* [Student](#Student)
* [Module hw03-bastion](#Module-hw03-bastion)

# Student
`
Student: Vadim Lyulin
Course: DevOps
Group: Otus-DevOps-2021-08
`

## Module hw12-docker-2" ������ VM � ������������� Docker Engine ��� ������ Docker Machine. ��������� Dockerfile � ������ ������ � �������� �����������. ���������� ������ �� DockerHub. <a name="Module-hw03-bastion"></a>
> ����: � ������ �� ������� ��������� �������� � Docker, ������� ������ ���������� � �������� �� � DockerHub.
> � ������ ������� ����������� ������: ������ � Docker, DockerHub.

1. ������� ����� docker-2
2. ������� ���������� dockermonolith
3. ���������� Docker � �������� � ������� ���������� hello-world
4. ���������� � �������� Yandex Cloud CLI
5. ���������� docker-machine
https://github.com/docker/machine/releases
```
$ curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
    chmod +x /tmp/docker-machine &&
    sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
```
6. ������ Docker ���� � Yandex Cloud
```
yc compute instance create \
  --name docker-host \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/id_rsa.pub

docker-machine create \
  --driver generic \
  --generic-ip-address=<���������_IP_���������_����_��������> \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/id_rsa \
  docker-host
  
eval $(docker-machine env docker-host)
```
7. ��������, ��� docker-host ������� ������
```
docker-machine ls
```
�����
```
NAME          ACTIVE   DRIVER    STATE     URL                        SWARM   DOCKER      ERRORS
docker-host   *        generic   Running   tcp://51.250.13.185:2376           v20.10.11
```

8. PID namespace (�������� ���������)

��������� ������� docker � � ��� ����������� ������������� process namespace ��� host ������.
�������:
```
docker run --rm -ti tehbilly/htop
```
![](img/without-pid-host.png)
�������:
```
docker run --rm --pid host -ti tehbilly/htop
```
![](img/with-pid-host.png)

�����: ��� �������������� ��������� --pid host ��� ���������� ���������� ����� ��� �������� host-������.

9. net namespace (�������� ����)
```
--network=host
```
If you use the host network mode for a container, that container�s network stack is not isolated from the Docker host 
(the container shares the host�s networking namespace), and the container does not get its own IP-address allocated. 
For instance, if you run a container which binds to port 80 and you use host networking, the container�s application 
is available on port 80 on the host�s IP address.

10. user namespaces (�������� �������������)
```
--userns=host
```
To disable user namespaces for a specific container, add the --userns=host flag to the docker container create, 
docker container run, or docker container exec command.
https://docs.docker.com/engine/security/userns-remap/

11. ������� ����� db_config Dockerfile mongod.conf start.sh 
12. ������ image reddit
```
docker build -t reddit:latest .
```
13. ������� ���������
```
docker run --name reddit -d --network=host reddit:latest
```
14. �������� ����������
```
docker-machine ls
```
�����:
```
NAME          ACTIVE   DRIVER    STATE     URL                        SWARM   DOCKER      ERRORS
docker-host   *        generic   Running   tcp://51.250.13.185:2376           v20.10.11
```

15. ��������� ����������� �� Docker hub
16. ��������� �������������� �� Docker Hub
```
docker login
```
�����
```
Login Succeeded
```

17. �������� ����� reddit �� docker hub
```
docker tag reddit:latest vlyulin/otus-reddit:1.0
docker push vlyulin/otus-reddit:1.0 
```
18. �������� ������ ������������ � Docker hub ������ � ��������� docker
```
docker run --name reddit -d -p 9292:9292 vlyulin/otus-reddit:1.0
```
19. �������� ����� ����������
```
docker logs reddit -f
```
20. ������� �������������� ������� bash � ����������
```
docker exec -it reddit bash
```
�����
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
21. ��������� ��������:
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
�����:
```
root@691a1a36b0f9:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.3  0.1  18244  3108 pts/0    Ss   11:25   0:00 bash
root        17  0.0  0.1  34424  2868 pts/0    R+   11:25   0:00 ps aux
root@691a1a36b0f9:/# exit
exit
```

�  �������  ���������  ������  �����  ����������  ���������
����������  �  ������,  �������  ������  ������������  ��������
����������, ��������� ���������� � ��������/������� ����� � ���������
����,  ���������  ���  �����  ���������  �  ��������  ����������  �������
��������� �� ���������:

```
docker inspect vlyulin/otus-reddit:1.0
```
�����:
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
�����:
```
[/bin/sh -c #(nop)  CMD ["/start.sh"]]
```

```
docker run --name reddit -d -p 9292:9292 vlyulin/otus-reddit:1.0
```
�����:
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

�����:
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
�����
```
bin   dev  home  lib64  mnt  proc    root  sbin  start.sh  tmp  var
boot  etc  lib   media  opt  reddit  run   srv   sys       usr
```
>**_Note_**: ���������� opt �� �����

### ������� �� *
>>>
�����  ����  �������  �����  �  �����������,  �����
����������������  ��������  ����������  ���������  �  Yandex  Cloud,
��������� �� ��� ������ � ������ ��� ������ /otus-reddit:1.0
- ����� ����������� � ���� ��������� � ���������� /docker-monolith/infra/
- �������� ��������� � ������� Terraform, �� ���������� �������� ����������;
- ��������� ��������� Ansible � �������������� ������������� ��������� ��� ��������� ������ � ������� ��� ������ ����������;
- ������ ������, ������� ������ ����� � ��� ������������� Docker;
>>>

1. ������� ���������� docker-monolith\infra\packer 
2. �������� inventory
��������� ����������������� yacloud_compute inventory plugin
>**_Note_**: ������� ����������� �� ���������� ansible
```
ansible -i environments/stage/yacloud_compute.yml --playbook-dir=./playbooks --list-hosts all
����� ��������� ansible.cfg
ansible --list-hosts all
```
�����:
```
  hosts (1):
    docker-host
```
3. ������� ���������� ./docker-monolith/infra/packer � ./docker-monolith/infra/ansible
4. ������� ��������������� ����� ������ image � ���������� /packer. 
������ ���� docker-monolith\infra\ansible\playbooks\install_docker.yml ��� ��������� docker � image ����������� packer.
� ����� packer/ubuntu-with-docker.json ������� ������������� install_docker.yml
```
    "provisioners": [
        {
            "type": "ansible",
            "playbook_file": "ansible/playbooks/install_docker.yml"
        }
```
5. �������� � ������ �����
```
packer validate -var-file=./packer/variables.json ./packer/ubuntu-with-docker.json
packer build -var-file=./packer/variables.json ./packer/ubuntu-with-docker.json
```
�����
```
Build 'yandex' finished after 3 minutes 56 seconds.

==> Wait completed after 3 minutes 56 seconds

==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: ubuntu-with-docker-1637950974 (id: fd87c49pj8rv80utnbd3) with family name ubuntu-with-docker
```

![](img/ubuntu-with-docker-image.png)

6. ������� ���������� ./docker-monolith/infra/terraform. 
� ����� Main.tf ������ ��������� packer ����� ����� ���������� var.disk_image
```
  boot_disk {
    initialize_params {
      image_id = var.disk_image
    }
  }
```

7. ������������������ terraform � ����������� ./terraform
```
init terraform
```
�����:
```
Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "yandex" (terraform-providers/yandex) 0.56.0...
```

8. ��������� �������� �������� terraform. ����������� �� ���������� ./terraform
```
terraform plan
```
�����
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

9. ������� ���������
```
terraform apply
```
�����
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

internal_ip_address_app = [
  "10.128.0.16",
  "10.128.0.13",
]
```

10. ������ ���� docker-monolith\infra\ansible\playbooks\install-reddit.yml ��� ��������� ���������� reddit

11. ��������� ��������� ���������� reddit ��� ���������� �� ��������� � docker.
����������� �� ���������� ./infra/ansible
�������� ������ ��������� docker.
```
ansible --list-hosts docker
```
�����
```
  hosts (2):
    docker-1
    docker-0
```
���������
```
ansible-playbook ./playbooks/install-reddit.yml --limit docker
```
12. �������� ����������������� ����������
http://<public ip>:9292
