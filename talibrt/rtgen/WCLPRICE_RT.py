import talibrt
from typing import List


class WCLPRICE_RT:
	def __init__(self):
		self.res, self._state = talibrt.WCLPRICE_StateInit()
	
	def __del__(self):
		self.res = talibrt.WCLPRICE_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.WCLPRICE_State(self._state, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.WCLPRICE_BatchState(self._state, inHigh, inLow, inClose)
		return a