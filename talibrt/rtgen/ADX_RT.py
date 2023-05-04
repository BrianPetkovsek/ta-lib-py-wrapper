import talibrt
from typing import List


class ADX_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.ADX_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.ADX_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.ADX_State(self._state, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.ADX_BatchState(self._state, inHigh, inLow, inClose)
		return a