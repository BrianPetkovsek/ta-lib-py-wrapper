import talibrt
from typing import List


class MINUS_DM_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.MINUS_DM_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.MINUS_DM_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float):
		self.res, *a = talibrt.MINUS_DM_State(self._state, inHigh, inLow)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float]):
		self.res, *a = talibrt.MINUS_DM_BatchState(self._state, inHigh, inLow)
		return a