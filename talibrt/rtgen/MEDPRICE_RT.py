import talibrt
from typing import List


class MEDPRICE_RT:
	def __init__(self):
		self.res, self._state = talibrt.MEDPRICE_StateInit()
	
	def __del__(self):
		self.res = talibrt.MEDPRICE_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float):
		self.res, *a = talibrt.MEDPRICE_State(self._state, inHigh, inLow)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float]):
		self.res, *a = talibrt.MEDPRICE_BatchState(self._state, inHigh, inLow)
		return a