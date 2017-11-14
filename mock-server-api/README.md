# BonusClub mock-server-api

#### Папка содержит данные для имитации серверного [REST API](https://ru.wikipedia.org/wiki/REST) с помощью простого сервера [typicode/json-server](https://github.com/typicode/json-server):

Сервер [typicode/json-server](https://github.com/typicode/json-server) нужно установить глобально с помощью **npm**
```
$ npm install -g json-server
```

Для запуска сервера используется командная строка:
```
\mock-server-api> json-server --watch db.json --routes routes.json --port 3030
```

Назначение файлов:
 * **db.json** - файл с данными
 * **routes.json** - файл с маршрутами
 