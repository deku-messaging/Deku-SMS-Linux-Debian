python=python3
pip=pip3
venv_path := $$HOME/.virtualenvs/deku

systemd_path=/usr/lib/systemd/system
pwd := $(shell pwd)

distro := $(shell cat /etc/*-release | grep ID_LIKE )

sys_service:install
	@mkdir -p installer/system
	@$(python) installer/generate.py
	@echo "complete"

install:requirements.txt copy_configs
	@$(python) -m virtualenv $(venv_path)
	@( \
		. $(venv_path)/bin/activate; \
		$(pip) install -r requirements.txt \
	)
	@git submodule update --init --recursive

copy_configs:
	@cp -nv .configs/example.config.ini .configs/config.ini
	@cp -nv .configs/events/example.rules.ini .configs/events/rules.ini
	@cp -nv .configs/isp/example.operators.ini .configs/isp/operators.ini
	@# @cp -nv .configs/extensions/example.config.ini .configs/extensions/config.ini
	@cp -nv .configs/extensions/example.authorize.ini .configs/extensions/authorize.ini
	@cp -nv .configs/extensions/example.labels.ini .configs/extensions/labels.ini
	@cp -nv .configs/extensions/platforms/example.telegram.ini .configs/extensions/platforms/telegram.ini

remove:
	@rm -rf $(venv_path)
	@sudo rm -v $(systemd_path)/deku.service
	@sudo systemctl daemon-reload
	@sudo systemctl kill deku.service
	@sudo systemctl disable deku.service
	@echo "complete"
