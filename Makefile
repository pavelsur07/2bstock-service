init: docker-down-clear account-clear \
	docker-pull docker-build docker-up account-init

up: docker-up
down: docker-down
restart: down up
check: lint validate-schema account-test #account-analyze
lint: account-lint
validate-schema: account-validate-schema

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down --remove-orphans

docker-down-clear:
	docker-compose down -v --remove-orphans

docker-pull:
	docker-compose pull --include-deps

docker-build:
	docker-compose build --pull

account-clear:
	docker run --rm -v ${PWD}/account:/app -w /app alpine sh -c 'rm -rf  .ready var/cache/* var/log/* var/test/*'

account-update: account-composer-update account-yarn-upgrade

account-init: account-permissions \
	account-composer-install account-assets-install \
	account-wait-db account-ready account-schema-update-force  \
	account-assets-build #account-migrations account-ready #account-fixtures account-ready

account-permissions:
	docker run --rm -v ${PWD}/account:/app -w /app alpine chmod 777 var/cache var/log var/test

account-console-wb-get-cards-list:
	docker-compose run --rm account-php-cli php bin/console app:wildberries:get-cards-list

account-console-wb-sales-stats:
	docker-compose run --rm account-php-cli php bin/console app:wildberries:sales-statistics --period=0

account-console-wb-orders-stats:
	docker-compose run --rm account-php-cli php bin/console app:wildberries:orders-statistics --period=0

account-console-download-external-image:
	docker-compose run --rm account-php-cli php bin/console app:syncing:download-external-image

account-console-update-analytics:
	docker-compose run --rm account-php-cli php bin/console app:report:update-clickhouse-analytics

account-composer-install:
	docker-compose run --rm account-php-cli composer install

account-composer-update:
	docker-compose run --rm account-php-cli composer update

account-assets-install:
	docker-compose run --rm account-node-cli yarn install
	#docker-compose run --rm account-node-cli npm rebuild node-sass

account-assets-build:
	docker-compose run --rm account-node-cli yarn build

account-yarn-upgrade:
	docker-compose run --rm account-node-cli yarn upgrade

account-oauth-keys:
	docker-compose run --rm account-php-cli mkdir -p var/oauth
	docker-compose run --rm account-php-cli openssl genrsa -out var/oauth/private.key 2048
	docker-compose run --rm account-php-cli openssl rsa -in var/oauth/private.key -pubout -out var/oauth/public.key
	docker-compose run --rm account-php-cli chmod 644 var/oauth/private.key var/oauth/public.key

account-wait-db:
	docker-compose run --rm account-php-cli wait-for-it account-postgres:5432 -t 30

account-migrations:
	docker-compose run --rm account-php-cli php bin/console doctrine:migrations:migrate --no-interaction

account-fixtures:
	docker-compose run --rm account-php-cli php bin/console doctrine:fixtures:load --no-interaction

account-backup:
	docker-compose run --rm account-postgres-backup

account-ready:
	docker run --rm -v ${PWD}/account:/app --workdir=/app alpine touch .ready

account-check: account-validate-schema account-lint account-test #account-analyze 

account-debug-router:
	docker-compose run --rm account-php-cli php bin/console debug:router

account-schema-update-dump-sql:
	docker-compose run --rm account-php-cli php bin/console doctrine:schema:update --dump-sql

account-schema-update-force:
	docker-compose run --rm account-php-cli php bin/console doctrine:schema:update --force

account-validate-schema:
	docker-compose run --rm account-php-cli php bin/console doctrine:schema:validate

account-lint:
	docker-compose run --rm account-php-cli composer lint
	docker-compose run --rm account-php-cli composer php-cs-fixer fix -- --dry-run --diff

account-cs-fix:
	docker-compose run --rm account-php-cli composer php-cs-fixer fix

account-analyze:
	docker-compose run --rm account-php-cli composer psalm -- --no-diff

account-analyze-diff:
	docker-compose run --rm account-php-cli composer psalm

account-test:
	docker-compose run --rm account-php-cli composer test

account-test-coverage:
	docker-compose run --rm account-php-cli composer test-coverage

account-test-unit:
	docker-compose run --rm account-php-cli composer test -- --testsuite=unit

account-test-unit-coverage:
	docker-compose run --rm account-php-cli composer test-coverage -- --testsuite=unit

account-test-functional:
	docker-compose run --rm account-php-cli composer test -- --testsuite=functional

account-test-functional-coverage:
	docker-compose run --rm account-php-cli composer test-coverage -- --testsuite=functional

validate-jenkins:
	curl --user ${USER} -X POST -F "jenkinsfile=<Jenkinsfile" ${HOST}/pipeline-model-converter/validate

#------------------------------------ build ------------------------------------------------
build:
	docker --log-level=debug build --pull --file=account/docker/production/nginx/Dockerfile --tag=${REGISTRY}/account:${IMAGE_TAG} account
	docker --log-level=debug build --pull --file=account/docker/production/php-fpm/Dockerfile --tag=${REGISTRY}/account-php-fpm:${IMAGE_TAG} account
	docker --log-level=debug build --pull --file=account/docker/production/php-cli/Dockerfile --tag=${REGISTRY}/account-php-cli:${IMAGE_TAG} account

try-build:
	REGISTRY=localhost IMAGE_TAG=0 make build

push: push-account

push-account:
	docker push ${REGISTRY}/account:${IMAGE_TAG}
	docker push ${REGISTRY}/account-php-fpm:${IMAGE_TAG}
	docker push ${REGISTRY}/account-php-cli:${IMAGE_TAG}

#---------------------  Deploy ----------------------------------
deploy-staging:
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'docker network create --driver=overlay traefik-public || true'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'rm -rf site_${BUILD_NUMBER}'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'mkdir site_${BUILD_NUMBER}'

	envsubst < docker-compose-staging.yml > docker-compose-staging-env.yml
	scp -o StrictHostKeyChecking=no -P ${PORT} docker-compose-staging-env.yml deploy@${HOST}:site_${BUILD_NUMBER}/docker-compose.yml
	rm -f docker-compose-staging-env.yml

	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && docker stack deploy --compose-file docker-compose.yml account --with-registry-auth --prune'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'rm -f site'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'ln -sr site_${BUILD_NUMBER} site'

deploy-clean-staging:
	rm -f docker-compose-staging-env.yml

deploy:
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'docker network create --driver=overlay traefik-public || true'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'rm -rf site_${BUILD_NUMBER}'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'mkdir site_${BUILD_NUMBER}'

	envsubst < docker-compose-production.yml > docker-compose-production-env.yml
	scp -o StrictHostKeyChecking=no -P ${PORT} docker-compose-production-env.yml deploy@${HOST}:site_${BUILD_NUMBER}/docker-compose.yml
	rm -f docker-compose-production-env.yml

	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && docker stack deploy --compose-file docker-compose.yml account --with-registry-auth --prune'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'rm -f site'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'ln -sr site_${BUILD_NUMBER} site'

deploy-clean:
	rm -f docker-compose-production-env.yml

rollback:
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && docker stack deploy --compose-file docker-compose.yml account --with-registry-auth --prune'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'rm -f site'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'ln -sr site_${BUILD_NUMBER} site'
