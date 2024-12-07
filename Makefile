SHELL=/bin/bash
# === USER PARAMETERS

ifdef OS
   export VENV_BIN=.venv/Scripts
else
   export VENV_BIN=.venv/bin
endif

export SRC_DIR=project_template
export PYTHONPATH='$(shell pwd)'
ifndef BRANCH_NAME
	export BRANCH_NAME=$(shell git rev-parse --abbrev-ref HEAD)
endif
DEPLOY_ENVIRONMENT=$(shell if [ $(findstring main, $(BRANCH_NAME)) ]; then \
			echo 'prod'; \
		elif [ $(findstring pre, $(BRANCH_NAME)) ]; then \
			echo 'pre'; \
		else \
		 	echo 'dev'; \
		fi)
# If use deploy_environment in the tag system
# `y` => yes
# `n` => no
USE_DEPLOY_ENVIRONMENT=n

# == SETUP REPOSITORY AND DEPENDENCIES

# Create or update the virtual environemnt.
# The project is relocked before syncing.
# This installs all extras and the development group (excluding the build group)
dev-sync:
	uv sync --cache-dir .uv_cache --all-extras

# As above but upgrades all packages
dev-sync-upgrade:
	uv sync --cache-dir .uv_cache --all-extras --upgrade

set-hooks:
	cp .hooks/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
	cp .hooks/pre-push .git/hooks/pre-push && chmod +x .git/hooks/pre-push
	cp .hooks/post-merge .git/hooks/post-merge && chmod +x .git/hooks/post-merge

setup: set-hooks dev-sync


# === CODE VALIDATION

format:
	. $(VENV_BIN)/activate && ruff format $(SRC_DIR)

lint:
	. $(VENV_BIN)/activate && ruff check $(SRC_DIR) --fix
	. $(VENV_BIN)/activate && mypy --ignore-missing-imports --install-types --non-interactive --package $(SRC_DIR)

test:
	. $(VENV_BIN)/activate && pytest --verbose --color=yes --cov=$(SRC_DIR) -n auto

all-validation: format lint test

# === DEPLOYMENT
docker:
	@# verify that version tag is set
	@[ -z "$(VERSION_TAG)" ] && echo VERSION_TAG is empty && exit 1 || echo "deploying $(VERSION_TAG)"

	@# the tag will have the following structure "vM.m.p@DE" where
	@# M is the major version
	@# m is the minor version
	@# p is the patch version
	@# DE is the deploy environment
	@# therefore, split by @ to get the DE or the versions
	@# then we split by v to remove it
	@# and finally we split by . to get the version level
	$(eval MAJOR=$(shell echo echo $(VERSION_TAG) | cut -d '@' -f 1 | cut -d 'v' -f 2 | cut -d '.' -f 1))
	$(eval MINOR=$(shell echo echo $(VERSION_TAG) | cut -d '@' -f 1 | cut -d 'v' -f 2 | cut -d '.' -f 2))
	$(eval PATCH=$(shell echo echo $(VERSION_TAG) | cut -d '@' -f 1 | cut -d 'v' -f 2 | cut -d '.' -f 3))
	$(eval DEPLOY_ENVIRONMENT=$(shell echo echo $(VERSION_TAG) | cut -d '@' -f 2))
	@echo "Version: $(VERSION_TAG)"
	@echo "Major: $(MAJOR)"
	@echo "Minor: $(MINOR)"
	@echo "Patch: $(PATCH)"
	@echo "DEPLOY_ENVIRONMENT: $(DEPLOY_ENVIRONMENT)"

	@# verify that variables are exported tag is set
	@[ -z "$(MAJOR)" ] && echo MAJOR is empty && exit 1 || echo "deploying $(MAJOR)"
	@[ -z "$(MINOR)" ] && echo MINOR is empty && exit 1 || echo "deploying $(MINOR)"
	@[ -z "$(PATCH)" ] && echo PATCH is empty && exit 1 || echo "deploying $(PATCH)"
	@[ -z "$(DEPLOY_ENVIRONMENT)" ] && echo DEPLOY_ENVIRONMENT is empty && exit 1 || echo "deploying $(DEPLOY_ENVIRONMENT)"

	@# build tags
	$(eval IMAGE_NAME=$(ECR_REPOSITORY)/image-name$(DEPLOY_ENVIRONMENT))
	$(eval MAJOR_TAG=$(IMAGE_NAME):$(MAJOR))
	$(eval MINOR_TAG=$(IMAGE_NAME):$(MAJOR).$(MINOR).$(PATCH))
	$(eval LATEST_TAG=$(IMAGE_NAME):latest)

	@echo $(IMAGE_NAME)
	@echo $(MAJOR_TAG)
	@echo $(MINOR_TAG)
	@echo $(LATEST_TAG)

	@# make login
	aws ecr get-login-password | sed -nE 's/(ey[a-zA-Z0-9=]+)/\1/p' | docker login --username AWS --password-stdin $(ECR_REPOSITORY)

	@# create docker image
	docker build \
		-t $(LATEST_TAG) -t $(MAJOR_TAG) -t $(MINOR_TAG) \
		. \
		--build-arg AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID) \
		--build-arg AWS_REGION=$(AWS_REGION) \
		--build-arg CODEARTIFACT_AUTH_TOKEN=$(CODEARTIFACT_AUTH_TOKEN) \
		--build-arg SECRET_SERVER_USERNAME=$(SECRET_SERVER_USERNAME) \
		--build-arg SECRET_SERVER_PWD=$(SECRET_SERVER_PWD)

	@# push the docker image to the repo
	@ echo pushing image to repo
	docker push $(IMAGE_NAME) --all-tags

docker-edge:
	@# verify that version tag is set
	@[ -z "$(VERSION_TAG)" ] && echo VERSION_TAG is empty && exit 1 || echo "deploying $(VERSION_TAG)"

	@# the tag will have the following structure "vM.m.p@DE" where
	@# M is the major version
	@# m is the minor version
	@# p is the patch version
	@# DE is the deploy environment
	@# therefore, split by @ to get the DE or the versions
	@# then we split by v to remove it
	@# and finally we split by . to get the version level
	$(eval MAJOR=$(shell echo echo $(VERSION_TAG) | cut -d '@' -f 1 | cut -d 'v' -f 2 | cut -d '.' -f 1))
	$(eval MINOR=$(shell echo echo $(VERSION_TAG) | cut -d '@' -f 1 | cut -d 'v' -f 2 | cut -d '.' -f 2))
	$(eval PATCH=$(shell echo echo $(VERSION_TAG) | cut -d '@' -f 1 | cut -d 'v' -f 2 | cut -d '.' -f 3))
	$(eval DEPLOY_ENVIRONMENT=$(shell echo echo $(VERSION_TAG) | cut -d '@' -f 2))
	@echo "Version: $(VERSION_TAG)"
	@echo "Major: $(MAJOR)"
	@echo "Minor: $(MINOR)"
	@echo "Patch: $(PATCH)"
	@echo "DEPLOY_ENVIRONMENT: $(DEPLOY_ENVIRONMENT)"

	@# verify that variables are exported tag is set
	@[ -z "$(MAJOR)" ] && echo MAJOR is empty && exit 1 || echo "deploying $(MAJOR)"
	@[ -z "$(MINOR)" ] && echo MINOR is empty && exit 1 || echo "deploying $(MINOR)"
	@[ -z "$(PATCH)" ] && echo PATCH is empty && exit 1 || echo "deploying $(PATCH)"
	@[ -z "$(DEPLOY_ENVIRONMENT)" ] && echo DEPLOY_ENVIRONMENT is empty && exit 1 || echo "deploying $(DEPLOY_ENVIRONMENT)"

	@# build tags
	$(eval IMAGE_NAME=ml3plt-edge-backend)
	$(eval MAJOR_TAG=$(IMAGE_NAME):$(MAJOR))
	$(eval MINOR_TAG=$(IMAGE_NAME):$(MAJOR).$(MINOR).$(PATCH))
	$(eval LATEST_TAG=$(IMAGE_NAME):latest)

	@echo $(IMAGE_NAME)
	@echo $(MAJOR_TAG)
	@echo $(MINOR_TAG)
	@echo $(LATEST_TAG)

	docker build \
		-t $(LATEST_TAG) -t $(MINOR_TAG) \
		-f Dockerfile-edge \
		. \
		--build-arg AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID) \
		--build-arg AWS_REGION=eu-west-3 \
		--build-arg CODEARTIFACT_AUTH_TOKEN=$(CODEARTIFACT_AUTH_TOKEN) \

client-swagger:
	python swagger_generator.py --target client
    
full-swagger:
	python swagger_generator.py --target full

deploy-tag:
	# This rule reads the current version tag, creates a new one with
	# the increment according to the variable KIND

	@# check if KIND variable is set
	@[ -z "$(KIND)" ] && echo KIND is empty && exit 1 || echo "creating tag $(KIND)"

	@# check if KIND variable has the allowed value
	@if [ "$${KIND}" != "major" -a "$${KIND}" != "minor" -a "$${KIND}" != "patch" ]; then \
		echo "Error: KIND environment variable must be set to 'major', 'minor', 'patch' or 'beta'."; \
		exit 1; \
	fi

	@# we add a prefix to the tag to specify the deploy environment
	$(eval DEPLOY_ENVIRONMENT_SUFFIX = @$(DEPLOY_ENVIRONMENT))

	@# read the current tag and export the three kinds
	@# to retrieve the version levels, we separate them by white space
	@# to do that we need to replace . and -
	@# then we keep the words number 1, 2, and 3
	$(eval CURRENT_TAG=$(shell git describe --tags --abbrev=0 --match="*@$(DEPLOY_ENVIRONMENT)"))
	$(eval MAJOR=$(shell echo echo $(CURRENT_TAG) | cut -d '@' -f 1 | cut -d 'v' -f 2 | cut -d '.' -f 1))
	$(eval MINOR=$(shell echo echo $(CURRENT_TAG) | cut -d '@' -f 1 | cut -d 'v' -f 2 | cut -d '.' -f 2))
	$(eval PATCH=$(shell echo echo $(CURRENT_TAG) | cut -d '@' -f 1 | cut -d 'v' -f 2 | cut -d '.' -f 3))
	@echo "Version: $(CURRENT_TAG)"
	@echo "Major: $(MAJOR)"
	@echo "Minor: $(MINOR)"
	@echo "Patch: $(PATCH)"

	@# according to the kind set the new tag
	@# I know it's strange but if blocks must be written without indentation
ifeq ($(KIND),major)
	$(eval MAJOR := $(shell echo $$(($(MAJOR) + 1))))
	$(eval MINOR := 0)
	$(eval PATCH := 0)
else ifeq ($(KIND),minor)
	$(eval MINOR := $(shell echo $$(($(MINOR) + 1))))
	$(eval PATCH := 0)
else ifeq ($(KIND),patch)
	$(eval PATCH := $(shell echo $$(($(PATCH) + 1))))
endif

	@# Set the new tag variable
	$(eval NEW_TAG=v$(MAJOR).$(MINOR).$(PATCH)$(DEPLOY_ENVIRONMENT_SUFFIX))
	$(eval MESSAGE=new version $(NEW_TAG))

	@echo $(NEW_TAG)
	@# create new tag
	git tag -a $(NEW_TAG) -m "$(MESSAGE)"

	@# push the tag
	git push origin $(NEW_TAG) --no-verify

deploy-tag-patch:
	@make deploy-tag KIND=patch

deploy-tag-minor:
	@make deploy-tag KIND=minor

deploy-tag-major:
	@make deploy-tag KIND=major