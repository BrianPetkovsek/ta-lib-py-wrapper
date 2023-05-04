import talibrt
from typing import List


class PLUS_DI_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.PLUS_DI_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.PLUS_DI_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.PLUS_DI_State(self._state, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.PLUS_DI_BatchState(self._state, inHigh, inLow, inClose)
		return a