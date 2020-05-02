from __future__ import print_function

import numpy
import talibrt
import sys

TEST_LEN = int(sys.argv[1]) if len(sys.argv) > 1 else 10000
LOOPS = int(sys.argv[2]) if len(sys.argv) > 2 else 1000

data = numpy.random.random(TEST_LEN)

if False: # fill array with nans
    data[:-1] = numpy.nan

import time
t0 = time.time()
for _ in range(LOOPS):
    talibrt.MA(data)
    talibrt.BBANDS(data)
    talibrt.KAMA(data)
    talibrt.CDLMORNINGDOJISTAR(data, data, data, data)
t1 = time.time()
print('test_len: %d, loops: %d' % (TEST_LEN, LOOPS))
print('time spend: %.6f' % (t1 - t0))
print('time per loop: %.6f' % ((t1 - t0) / LOOPS))

print('\nTest batch state functions:\n')
t0 = time.time()
res, ma_state = talibrt.MA_StateInit()
res, bbands_state = talibrt.BBANDS_StateInit()
res, kama_state = talibrt.KAMA_StateInit()
res, star_state = talibrt.CDLMORNINGDOJISTAR_StateInit()

for _ in range(LOOPS):
    talibrt.MA_BatchState(ma_state, data)
    talibrt.BBANDS_BatchState(bbands_state, data)
    talibrt.KAMA_BatchState(kama_state, data)
    talibrt.CDLMORNINGDOJISTAR_BatchState(star_state, data, data, data, data)

res = talibrt.MA_StateFree(ma_state)
res = talibrt.BBANDS_StateFree(bbands_state)
res = talibrt.KAMA_StateFree(kama_state)
res = talibrt.CDLMORNINGDOJISTAR_StateFree(star_state)
t1 = time.time()

print('test_len: %d, loops: %d' % (TEST_LEN, LOOPS))
print('time spend: %.6f' % (t1 - t0))
print('time per loop: %.6f' % ((t1 - t0) / LOOPS))

print('\nTest state functions:\n')
t0 = time.time()
res, ma_state = talibrt.MA_StateInit()
res, bbands_state = talibrt.BBANDS_StateInit()
res, kama_state = talibrt.KAMA_StateInit()
res, star_state = talibrt.CDLMORNINGDOJISTAR_StateInit()

for _ in range(LOOPS):
    for d in data:
        res, val = talibrt.MA_State(ma_state, d)
        res, val1, va2, val3 = talibrt.BBANDS_State(bbands_state, d)
        res, val = talibrt.KAMA_State(kama_state, d)
        res, val = talibrt.CDLMORNINGDOJISTAR_State(star_state, d, d, d, d)

res = talibrt.MA_StateFree(ma_state)
res = talibrt.BBANDS_StateFree(bbands_state)
res = talibrt.KAMA_StateFree(kama_state)
res = talibrt.CDLMORNINGDOJISTAR_StateFree(star_state)
t1 = time.time()

print('test_len: %d, loops: %d' % (TEST_LEN, LOOPS))
print('time spend: %.6f' % (t1 - t0))
print('time per loop: %.6f' % ((t1 - t0) / LOOPS))
