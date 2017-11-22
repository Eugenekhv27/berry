# Средства имитации **back end** сервера для **front end** разработки

## Директория **\mock-server-api**

Имитация серверного [REST API](https://ru.wikipedia.org/wiki/REST) выполняется с помощью простого сервера [typicode/json-server](https://github.com/typicode/json-server). Данные для имитации находятся в директории **\mock-server-api**. Назначение файлов:

 * **db.json** - файл с данными
 * **routes.json** - файл с маршрутами

Сервер [typicode/json-server](https://github.com/typicode/json-server) нужно установить глобально:
```
$ npm install -g json-server
```

Для запуска сервера используется командная строка:
```
\mock-server-api> json-server --watch db.json --routes routes.json --port 3030
```

Или шорткат для npm:
```
$ npm run json-server
```
 