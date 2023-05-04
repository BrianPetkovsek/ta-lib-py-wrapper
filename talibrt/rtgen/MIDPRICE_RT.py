import talibrt
from typing import List


class MIDPRICE_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.MIDPRICE_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.MIDPRICE_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float):
		self.res, *a = talibrt.MIDPRICE_State(self._state, inHigh, inLow)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float]):
		self.res, *a = talibrt.MIDPRICE_BatchState(self._state, inHigh, inLow)
		return a