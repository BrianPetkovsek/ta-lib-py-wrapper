import talibrt
from typing import List


class CDLHANGINGMAN_RT:
	def __init__(self):
		self.res, self._state = talibrt.CDLHANGINGMAN_StateInit()
	
	def __del__(self):
		self.res = talibrt.CDLHANGINGMAN_StateFree(self._state)
	
	def state(self, inOpen: float, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.CDLHANGINGMAN_State(self._state, inOpen, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inOpen: List[float], inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.CDLHANGINGMAN_BatchState(self._state, inOpen, inHigh, inLow, inClose)
		return a