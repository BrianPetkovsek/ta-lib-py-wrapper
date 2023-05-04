#!/usr/bin/env python

import sys
import os
import warnings

from distutils.dist import Distribution

display_option_names = Distribution.display_option_names + ['help', 'help-commands']
query_only = any('--' + opt in sys.argv for opt in display_option_names) or len(sys.argv) < 2 or sys.argv[1] == 'egg_info'

try:
    from setuptools import setup, Extension, find_packages
    requires = {"install_requires": ["numpy"]}
except:
    from distutils.core import setup, find_packages
    from distutils.extension import Extension
    requires = {"requires": ["numpy"]}

lib_talib_name = 'ta-lib-rt'  # the underlying C library's name

runtime_lib_dirs = []

platform_supported = False
for prefix in ['darwin', 'linux', 'bsd', 'sunos']:
    if prefix in sys.platform:
        platform_supported = True
        include_dirs = [
            '/usr/include',
            '/usr/local/include',
            '/opt/include',
            '/opt/local/include',
        ]
        if 'TA_INCLUDE_PATH' in os.environ:
            include_dirs.append(os.environ['TA_INCLUDE_PATH'])
        lib_talib_dirs = [
            '/usr/lib',
            '/usr/local/lib',
            '/usr/lib64',
            '/usr/local/lib64',
            '/opt/lib',
            '/opt/local/lib',
        ]
        if 'TA_LIBRARY_PATH' in os.environ:
            runtime_lib_dirs = os.environ['TA_LIBRARY_PATH']
            if runtime_lib_dirs:
                runtime_lib_dirs = runtime_lib_dirs.split(os.pathsep)
                lib_talib_dirs.extend(runtime_lib_dirs)
        break

if sys.platform == "win32":
    here = os.path.abspath(os.path.dirname(__file__))
    platform_supported = True
    lib_talib_name = 'libta-lib-rt'
    include_dirs = [here+"/ta-lib-rt/c/include"]
    lib_talib_dirs = [here+"/ta-lib-rt/c/lib"]

if not platform_supported:
    raise NotImplementedError(sys.platform)

# Do not require numpy or cython for just querying the package
if not query_only:
    import numpy
    include_dirs.insert(0, numpy.get_include())

try:
    from Cython.Distutils import build_ext
    has_cython = True
except ImportError:
    has_cython = False

for lib_talib_dir in lib_talib_dirs:
    try:
        files = os.listdir(lib_talib_dir)
        if any(lib_talib_name in f for f in files):
            break
    except OSError:
        pass
else:
    warnings.warn('Cannot find ta-lib-rt library, installation may fail.')

cmdclass = {}
if has_cython:
    cmdclass['build_ext'] = build_ext

ext_modules = [
    Extension(
        'talibrt._ta_lib',
        ['talibrt/_ta_lib.pyx' if has_cython else 'talibrt/_ta_lib.c'],
        include_dirs=include_dirs,
        library_dirs=lib_talib_dirs,
        libraries=[lib_talib_name],
        runtime_library_dirs=runtime_lib_dirs
    )
]


header_found = False
for path in include_dirs:
    ta_func_header = os.path.join(path, 'ta-lib-rt', 'ta_func.h')
    if os.path.exists(ta_func_header):
        header_found = True
        break
    ta_func_header = os.path.join(path, 'ta-lib', 'ta_func.h')
    if os.path.exists(ta_func_header):
        header_found = True
        break
if header_found:
    print('(ta-lib/ta_func.h or ta-lib-rt/ta_func.h) found', file=sys.stdout)
    from tools.gencode import gencode
    gencode(ta_func_header)
else:
    print('Error: (ta-lib/ta_func.h or ta-lib-rt/ta_func.h) not found wont generate helper wrapper code', file=sys.stderr)

setup(
    name = 'TA-Lib-RT',
    version = '0.8.1-alpha',
    description = 'Python wrapper for TA-Lib-RT',
    author = 'John Benediktsson',
    author_email = 'mrjbq7@gmail.com',
    url = 'https://github.com/trufanov-nok/ta-lib-rt',
    download_url = 'https://github.com/trufanov-nok/ta-lib-rt/releases',
    classifiers = [
        "License :: OSI Approved :: BSD License",
        "Development Status :: 4 - Beta",
        "Operating System :: Unix",
        "Operating System :: POSIX",
        "Operating System :: MacOS :: MacOS X",
        "Operating System :: Microsoft :: Windows",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3.3",
        "Programming Language :: Python :: 3.4",
        "Programming Language :: Python :: 3.5",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Cython",
        "Topic :: Office/Business :: Financial",
        "Topic :: Scientific/Engineering :: Mathematics",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "Intended Audience :: Financial and Insurance Industry",
    ],
    packages = find_packages(),
    ext_modules = ext_modules,
    cmdclass = cmdclass,
    **requires
)
