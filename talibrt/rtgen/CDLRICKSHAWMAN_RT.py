import talibrt
from typing import List


class CDLRICKSHAWMAN_RT:
	def __init__(self):
		self.res, self._state = talibrt.CDLRICKSHAWMAN_StateInit()
	
	def __del__(self):
		self.res = talibrt.CDLRICKSHAWMAN_StateFree(self._state)
	
	def state(self, inOpen: float, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.CDLRICKSHAWMAN_State(self._state, inOpen, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inOpen: List[float], inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.CDLRICKSHAWMAN_BatchState(self._state, inOpen, inHigh, inLow, inClose)
		return a