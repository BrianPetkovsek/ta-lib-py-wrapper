import talibrt
from typing import List


class SAR_RT:
	def __init__(self, optInAcceleration: float, optInMaximum: float):
		self.res, self._state = talibrt.SAR_StateInit(optInAcceleration, optInMaximum)
	
	def __del__(self):
		self.res = talibrt.SAR_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float):
		self.res, *a = talibrt.SAR_State(self._state, inHigh, inLow)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float]):
		self.res, *a = talibrt.SAR_BatchState(self._state, inHigh, inLow)
		return a