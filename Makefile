.PHONY: build

build:
	python3 setup.py build_ext --inplace

install:
	python3 setup.py install

talib/_func.pxi: tools/generate_func.py
	python3 tools/generate_func.py > talibrt/_func.pxi

generate: talib/_func.pxi

cython:
	cython -3 --directive emit_code_comments=False talibrt/_ta_lib.pyx

clean:
	rm -rf build talibrt/_ta_lib.so talibrt/*.pyc

perf:
	python3 tools/perf_talib.py

test: build
	LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH} nosetests

sdist:
	python3 setup.py sdist --formats=gztar,zip
