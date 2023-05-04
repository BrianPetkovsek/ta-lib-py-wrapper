import talibrt
from typing import List


class MINUS_DI_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.MINUS_DI_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.MINUS_DI_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.MINUS_DI_State(self._state, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.MINUS_DI_BatchState(self._state, inHigh, inLow, inClose)
		return a