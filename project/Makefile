# Module creation

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
