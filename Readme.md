<h2>Развернуть пример реализации микросервисов на основе готового репозитория на GitHub</h2>
<h3>Описание:</h3>

Для зачета по итоговому заданию модуля достаточно предоставить GitHub-репозиторий с работающим решением по развертыванию интернет-магазина носков
в одном из публичных провайдеров. Для Yandex.Сloud это может быть Swarm или Nomad, для Amazon — это ECS.<br><br>

Кроме репозитория необходимо предоставить скриншоты работающего интернет-магазина. На одном скриншоте должны быть видны интернет-магазин
и адресная строка.<br><br>

Описание инфраструктуры необходимо зафиксировать как код в одном из инструментов, который вам больше подходит.<br>
Это может быть Terraform, Cloudformation или что-то другое.<br><br>

В приведенном репозитории присутствуют ошибки, поэтому вам нужно самостоятельно описать IaC или использовать код из репозитория для того чтобы создать
работающий проект, который мы ранее запускали в Swarm.<br><br>

<h3>Задание:</h3>

1. Описать через IaC интернет-магазин носков.<br>
<b>Ответ: Для реализации задания было выбрано решение Terrsform + Docker Swarm в Yandex.Сloud <br>
Миниинструкция <br>
a. Для запуска данного проекта нужен сервер в Yandex.Сloud с установленным и настроенным terraform. <br>
b. Нужно сделать git clone https://github.com/awerton89/D1.7.git проекта к себе на сервер. <br>
c. Настроить провайдера яндекс в variables.tf, указать token, cloude id, folder id от своего облака yandex <br>
d. Указать нужное колличество серверов в Main.tf <br>
e. Указать нужное количество репликаций для сервисов проекта в modules/instance/provisioning.tf <br>
f. Инициализировать terraform командой terraform init  <br>
g. Далее можно произвести деплой проекта командой terraform apply   <br>
h. Для входа на серверы кластера нужно использовать ssh ключи которые будут созданы при деплое проекта. Ключи <br>
будут созданы в папке /ssh_key проекта. Команада для подключения: <br>
ssh -i ssh_key/id_rsa ubuntu@ip_address </b><br><br>
2. Развернуть проект. <br>
<b>Ответ: Проект развёрнут. </b><br>
<img src="https://github.com/Suirus777/Project_d_1.7/blob/master/skreenshots/node_for_cluster_docker_swarm.JPG">
<br>
3. Сделать скриншоты.<br>
<b>Скриншот магазина с основной ноды "Manager" кластера Docker Swarm </b> <br>
<img src="https://github.com/Suirus777/Project_d_1.7/blob/master/skreenshots/socks_shop_manager_node.JPG">
<b>Ответ: Cкриншоты магазина с остальных нод можно посмотреть по пути /skreenshots/  </b><br><br>

4. Предоставить доступ к репозиторию и скриншотам для проверки. <br>
<b>Ответ: https://github.com/awerton89/D1.7.git  </b><br><br>
