# Define targets
.PHONY: install test build build-deb clean

# Define variables
PYTHON := python3
PI := $(PYTHON) -m pip
PYINSTALLER := $(PYTHON) -m PyInstaller
DEB := $(shell pwd)/assets/deb
DEBLIB := $(DEB)/usr/lib


# Default target
default: install test build

# Target to install dependencies
install:
	$(PI) install -r requirements.txt 
	$(PI) install .

# Target to run tests
test:
	$(PYTHON) -m unittest discover -s tests -p 'test_*.py' -f -v

# Target to create an executable using PyInstaller
build: install
	$(PI) install --upgrade pyinstaller
	$(PYINSTALLER) main.py \
	--onefile \
	--exclude pandas \
	--paths $(shell pwd) \
	--distpath dist/$(shell uname) \
	--workpath build/$(shell uname) \
	--log-level INFO \
	--exclude numpy \
	--exclude matplotlib \
	--exclude PyQt5 \
	--exclude PyQt6 \
	--exclude share \
	--icon assets/logo.png \
	--noconfirm

# Target to create .deb file
build-deb: install
	$(PYINSTALLER) main.py \
	--onedir \
	--exclude pandas \
	--paths $(shell pwd) \
	--distpath $(DEBLIB) \
	--workpath build/$(shell uname) \
	--log-level INFO \
	--exclude numpy \
	--exclude matplotlib \
	--exclude PyQt5 \
	--exclude PyQt6 \
	--exclude share \
	--name pytgpt \
	--contents-directory . \
	--noconfirm

	echo "/usr/lib/pytgpt\n"\
	"/usr/bin/pytgpt\n"\
	"/usr/share/applications/icons/pytgpt.png\n"\
	"/usr/share/applications/pytgpt.desktop" > $(DEBLIB)/pytgpt/entries.txt

	cp assets/logo.png $(DEB)/usr/share/applications/icons/pytgpt.png

	dpkg-deb --build $(DEB) pytgpt.deb


# Target to clean up build artifacts
clean:
	rm -rf build/ dist/ *.spec *.deb
