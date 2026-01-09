.DEFAULT_GOAL := usage

# user and repo
USER        = $$(whoami)
CURRENT_DIR = $(notdir $(shell pwd))

# terminal colours
RED     = \033[0;31m
GREEN   = \033[0;32m
YELLOW  = \033[0;33m
NC      = \033[0m
# versions
APP_REVISION    = $(shell git rev-parse HEAD)

.PHONY: install
install:
	bundle install

	docker run --name friendly-postgres-container \
	-e POSTGRES_USER=friendlyantz \
	-e POSTGRES_PASSWORD=password \
	-e POSTGRES_DB=take_on_me_development \
	-p 5432:5432 \
	-d postgres

.PHONY: test
test:
	bundle exec rspec

.PHONY: server
server:
	bundle exec rails server

.PHONY: tailwind
tailwind:
	bin/rails tailwindcss:watch

.PHONY: load_deploy_secrets
load_deploy_secrets:
	bw unlock

.PHONY: letter_opener
letter_opener:
	open http://localhost:3000/letter_opener

.PHONY: deploy
deploy:
	kamal deploy

.PHONY: console
console:
	kamal console

.PHONY: js_outdated
js_outdated:
	./bin/importmap outdated

.PHONY: js_audit
js_audit:
	./bin/importmap audit

.PHONY: lint
lint:
	rake standard:fix

.PHONY: lint_unsafe
lint_unsafe:
	rake standard:fix_unsafely

.PHONY: lint_checkonly
lint_checkonly:
	rake standard

.PHONY: lint_erb_partial
lint_erb_partial:
	bundle exec erb_lint --enable-linters partial_instance_variable --lint-all

# .PHONY: audit_dependencies
# audit_dependencies:
# 	bundle exec bundle-audit

# .PHONY: ci
# ci: lint_checkonly audit_dependencies test

.PHONY: usage
usage:
	@echo
	@echo "Hi ${GREEN}${USER}!${NC} Welcome to ${RED}${CURRENT_DIR}${NC}"
	@echo
	@echo "Getting started"
	@echo
	@echo "${YELLOW}make install${NC}                  install dependencies"
	@echo
	@echo "${YELLOW}make server${NC}                   run server"
	@echo "${YELLOW}make tailwind${NC}                 run tailwind watcher"
	@echo "${YELLOW}make letter_opener${NC}            open email preview in browser"
	@echo
# 	@echo "${YELLOW}make test${NC}                     run tests"
	@echo
	@echo "before deploying run: export EMAIL=your@email.com"
	@echo "${YELLOW}make load_deploy_secrets${NC}      load deploy secrets. then manually export SESSION_TOKEN"
	@echo "${YELLOW}make deploy${NC}                   deploy"
	@echo "${YELLOW}make console${NC}                  prod console"
	@echo
	@echo "${YELLOW}make run${NC}                      launch app"
	@echo
	@echo "${YELLOW}make js_outdated${NC}              check for outdated js dependencies (${RED}NEVER run importmap update${NC}, as it will dowload js dependencies locally, which will break FireFox due to strickt CORS policies)"
	@echo "${YELLOW}make js_audit${NC}                 audit js dependencies,"
	@echo
	@echo "${YELLOW}make lint${NC}                     lint app"
	@echo "${YELLOW}make lint_unsafe${NC}              lint app(UNSAFE)"
	@echo "${YELLOW}make lint_checkonly${NC}           check lintintg"
	@echo "${YELLOW}make lint_erb_partial${NC}         lint erb partials for instance variables"
# 	@echo "${YELLOW}make audit_dependencies${NC}       security audit of dependencies"
# 	@echo "${YELLOW}make ci${NC}                       ci to check linting and run tests"
	@echo
