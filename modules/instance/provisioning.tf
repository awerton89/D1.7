# Создаём ssh ключ для нашего проекта
resource "null_resource" "ssh_key" {
   provisioner "local-exec" {
     command = "rm -f ssh_key/id_rsa* && ssh-keygen -t rsa -b 4096 -N '' -f ssh_key/id_rsa"
  }
}

resource "null_resource" "docker-swarm-manager" {
  count = var.managers
  depends_on = [yandex_compute_instance.vm-manager]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm-manager[count.index].network_interface.0.nat_ip_address
  }

  provisioner "file" {
    source      = "docker-compose/docker-compose-v3.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com | sh",
      "sudo usermod -aG docker $USER",
      "sudo apt install -y docker-compose",
      "sudo docker swarm init",
      "sleep 10",
      "echo COMPLETED"
    ]
  }
}

resource "null_resource" "docker-swarm-manager-join" {
  count = var.managers
  depends_on = [yandex_compute_instance.vm-manager, null_resource.docker-swarm-manager]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm-manager[count.index].network_interface.0.nat_ip_address
  }

  provisioner "local-exec" {
    command = "TOKEN=$(ssh -i ${var.ssh_credentials.private_key} -o StrictHostKeyChecking=no ${var.ssh_credentials.user}@${yandex_compute_instance.vm-manager[count.index].network_interface.0.nat_ip_address} docker swarm join-token -q worker); echo \"#!/usr/bin/env bash\nsudo docker swarm join --token $TOKEN ${yandex_compute_instance.vm-manager[count.index].network_interface.0.nat_ip_address}:2377\nexit 0\" >| join.sh"
  }
}

resource "null_resource" "docker-swarm-worker" {
  count = var.workers
  depends_on = [yandex_compute_instance.vm-worker, null_resource.docker-swarm-manager-join]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm-worker[count.index].network_interface.0.nat_ip_address
  }

  provisioner "file" {
    source      = "join.sh"
    destination = "/home/ubuntu/join.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com | sh",
      "sudo usermod -aG docker $USER",
      "chmod +x /home/ubuntu/join.sh",
      "~/join.sh"
    ]
  }
}

resource "null_resource" "docker-swarm-manager-start" {
  depends_on = [yandex_compute_instance.vm-manager, null_resource.docker-swarm-manager-join]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm-manager[0].network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
        "docker stack deploy --compose-file /home/ubuntu/docker-compose.yml sockshop-swarm", # деплоим стэк магазина в кластер Docker swarm
        "docker service update --replicas 2 sockshop-swarm_front-end"              # увеличиваем количество репликаций для сервиса sockshop-swarm_front-end
#        "docker service update --replicas 2 sockshop-swarm_carts",                # увеличиваем количество репликаций для сервиса sockshop-swarm_carts
#        "docker service update --replicas 2 sockshop-swarm_carts-db",             # увеличиваем количество репликаций для сервиса sockshop-swarm_carts-db
#        "docker service update --replicas 2 sockshop-swarm_catalogue",            # увеличиваем количество репликаций для сервиса sockshop-swarm_catalogue
#        "docker service update --replicas 2 sockshop-swarm_catalogue-db",         # увеличиваем количество репликаций для сервиса sockshop-swarm_catalogue-db
#        "docker service update --replicas 2 sockshop-swarm_edge-router",          # увеличиваем количество репликаций для сервиса sockshop-swarm_edge-router
#        "docker service update --replicas 2 sockshop-swarm_orders",               # увеличиваем количество репликаций для сервиса sockshop-swarm_orders
#        "docker service update --replicas 2 sockshop-swarm_orders-db",            # увеличиваем количество репликаций для сервиса sockshop-swarm_orders-db
#        "docker service update --replicas 2 sockshop-swarm_payment",              # увеличиваем количество репликаций для сервиса sockshop-swarm_payment
#        "docker service update --replicas 2 sockshop-swarm_queue-master",         # увеличиваем количество репликаций для сервиса sockshop-swarm_queue-master
#        "docker service update --replicas 2 sockshop-swarm_rabbitmq",             # увеличиваем количество репликаций для сервиса sockshop-swarm_rabbitmq
#        "docker service update --replicas 2 sockshop-swarm_shipping"              # увеличиваем количество репликаций для сервиса sockshop-swarm_shipping
   ]
  }
  
  provisioner "local-exec" {
    command = "rm join.sh"
  }

}
