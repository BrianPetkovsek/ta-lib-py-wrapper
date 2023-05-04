import talibrt
from typing import List


class WILLR_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.WILLR_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.WILLR_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.WILLR_State(self._state, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.WILLR_BatchState(self._state, inHigh, inLow, inClose)
		return a