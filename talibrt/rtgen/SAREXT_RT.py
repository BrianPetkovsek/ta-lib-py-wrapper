import talibrt
from typing import List


class SAREXT_RT:
	def __init__(self, optInStartValue: float, optInOffsetOnReverse: float, optInAccelerationInitLong: float, optInAccelerationLong: float, optInAccelerationMaxLong: float, optInAccelerationInitShort: float, optInAccelerationShort: float, optInAccelerationMaxShort: float):
		self.res, self._state = talibrt.SAREXT_StateInit(optInStartValue, optInOffsetOnReverse, optInAccelerationInitLong, optInAccelerationLong, optInAccelerationMaxLong, optInAccelerationInitShort, optInAccelerationShort, optInAccelerationMaxShort)
	
	def __del__(self):
		self.res = talibrt.SAREXT_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float):
		self.res, *a = talibrt.SAREXT_State(self._state, inHigh, inLow)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float]):
		self.res, *a = talibrt.SAREXT_BatchState(self._state, inHigh, inLow)
		return a