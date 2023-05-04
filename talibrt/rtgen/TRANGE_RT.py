import talibrt
from typing import List


class TRANGE_RT:
	def __init__(self):
		self.res, self._state = talibrt.TRANGE_StateInit()
	
	def __del__(self):
		self.res = talibrt.TRANGE_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.TRANGE_State(self._state, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.TRANGE_BatchState(self._state, inHigh, inLow, inClose)
		return a