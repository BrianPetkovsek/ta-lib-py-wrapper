import talibrt
from typing import List


class ULTOSC_RT:
	def __init__(self, optInTimePeriod1: int, optInTimePeriod2: int, optInTimePeriod3: int):
		self.res, self._state = talibrt.ULTOSC_StateInit(optInTimePeriod1, optInTimePeriod2, optInTimePeriod3)
	
	def __del__(self):
		self.res = talibrt.ULTOSC_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.ULTOSC_State(self._state, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.ULTOSC_BatchState(self._state, inHigh, inLow, inClose)
		return a