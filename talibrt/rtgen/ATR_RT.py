import talibrt
from typing import List


class ATR_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.ATR_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.ATR_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.ATR_State(self._state, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.ATR_BatchState(self._state, inHigh, inLow, inClose)
		return a