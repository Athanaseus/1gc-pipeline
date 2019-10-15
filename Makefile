
.PHONY : run

.DEFAULT_GOAL := run

MS=small_eso.ms


input/$(MS).tar:
	cd input && wget https://archive.kernsuite.info/data/$(MS).tar

input/$(MS): input/$(MS).tar
	cd input && tar xvf $(MS).tar
	touch input/$(MS)

.venv/:
	python3 -m venv .venv
	.venv/bin/pip install --upgrade pip

.venv/bin/cwltoil: .venv/
	.venv/bin/pip install -r requirements.txt

run: .venv/bin/cwltoil input/$(MS)
	.venv/bin/cwltoil 1GC-pipeline.cwl 1GC-pipeline.yml

all: run
