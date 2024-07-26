Все команды автоматизации указаны в MakeFile
для инициализации проекта запускаем команду make init

LOCALHOST:

    localhos
    mailer.localhost
    wiremock.localhost
    backup-storage.localhost

Development
Комманды 
- make init запустить окружение
- make check полная проверка приложения на код стайл, типизацию, соответствие схем бд, проверка всех тестов
- make down выключение окружения

Staging

Jenkins автоматически проверяет обнавление в ветки "staging", в случае появления нового комита 
производит все проверки и тесты идентичные как для Prodaction. Отличия в том, что добовляется
дополнительный контейнер account-stage-php-cli содержащий в себе все билиотеки раздела --dev файла 
composer.yml в том числе и библиотеку для заполнения фикстур.

Staging - доступен по адресу staging.account.2bstock.ru