
# Test

test:
	TUIST_ROOT_DIR=${PWD} tuist test

# Project generation

generate:
	TUIST_ROOT_DIR=${PWD} tuist generate

genModule:
	TUIST_ROOT_DIR=${PWD} tuist generate ${name}

# Module generation

USER_NAME = $(shell python3 Scaffold/Scripts/author_name.py)
CURRENT_DATE = $(shell pipenv run python Scaffold/Scripts/current_date.py)

Feature:
	@mkdir -p Projects/Presentation/Feature/${name};
	@tuist scaffold Feature \
	--project-name ${name} \
	--author "$(USER_NAME)" \
	--current-date "$(CURRENT_DATE)";
	@rm Pipfile >/dev/null 2>&1;
	@tuist edit
