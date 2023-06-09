.ONESHELL:
ENV_PREFIX=$(shell python -c "if __import__('pathlib').Path('venv/bin/pip').exists(): print('venv/bin/')")

.PHONY: help
help:             ## Show the help.
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@fgrep "##" Makefile | fgrep -v fgrep


.PHONY: show
show:             ## Show the current environment.
	@echo "Current environment:"
	@echo "Running using $(ENV_PREFIX)"
	@$(ENV_PREFIX)python -V
	@$(ENV_PREFIX)python -m site

.PHONY: install
install:          ## Install the project in dev mode.
	@echo "Don't forget to run 'make virtualenv' if you got errors."
	$(ENV_PREFIX)pip install -e .[test]

.PHONY: fmt
fmt:              ## Format code using black & isort.
	$(ENV_PREFIX)isort service_v2/
	$(ENV_PREFIX)black -l 79 service_v2/
	$(ENV_PREFIX)black -l 79 tests/

.PHONY: lint
lint:             ## Run pep8, black, mypy linters.
	@echo "Running flake8"
	$(ENV_PREFIX)flake8 service_v2/
	@echo "Running black"
	$(ENV_PREFIX)black -l 79 --check service_v2/
	$(ENV_PREFIX)black -l 79 --check tests/

.PHONY: virtualenv
virtualenv:       ## Create a virtual environment.
	@echo "creating virtualenv ..."
	@rm -rf venv
	@python3 -m venv venv
	@./venv/bin/pip install -U pip
	@./venv/bin/pip install -e .[test]
	@echo
	@echo "!!! Please run 'source venv/bin/activate' to enable the environment !!!"

.PHONY: test
test: lint   ## Run tests and generate coverage report.
	$(ENV_PREFIX)pytest -v --cov-config .coveragerc --cov=service_v2 -l --tb=short --maxfail=1 tests/
	$(ENV_PREFIX)coverage xml
	$(ENV_PREFIX)coverage html

.PHONY: watch
watch:            ## Run tests on every change.
	ls **/**.py | entr $(ENV_PREFIX)pytest -s -vvv -l --tb=long --maxfail=1 tests/

.PHONY: clean
clean:            ## Clean unused files.
	@find ./ -name '*.pyc' -exec rm -f {} \;
	@find ./ -name '__pycache__' -exec rm -rf {} \;
	@find ./ -name 'Thumbs.db' -exec rm -f {} \;
	@find ./ -name '*~' -exec rm -f {} \;
	@rm -rf .cache
	@rm -rf .pytest_cache
	@rm -rf .mypy_cache
	@rm -rf build
	@rm -rf dist
	@rm -rf *.egg-info
	@rm -rf htmlcov
	@rm -rf .tox/
	@rm -rf docs/_build


#.PHONY: release
#release:          ## Create a new tag for release.
#	@echo "WARNING: This operation will create s version tag and push to github"
#	@read -p "Version? (provide the next x.y.z semver) : " TAG
#	@echo "$${TAG}" > service_v2/VERSION
#	@$(ENV_PREFIX)gitchangelog > HISTORY.md
#	@git add service_v2/VERSION HISTORY.md
#	@git commit -m "release: version $${TAG} 🚀"
#	@echo "creating git tag : $${TAG}"
#	@git tag $${TAG}
#	@git push -u origin HEAD --tags
#	@echo "Github Actions will detect the new tag and release the new version."

.PHONY: docs
docs:             ## Build the documentation.
	@echo "building documentation ..."
	@$(ENV_PREFIX)mkdocs build
	URL="site/index.html"; xdg-open $$URL || sensible-browser $$URL || x-www-browser $$URL || gnome-open $$URL
