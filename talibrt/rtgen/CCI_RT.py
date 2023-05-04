import talibrt
from typing import List


class CCI_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.CCI_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.CCI_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.CCI_State(self._state, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.CCI_BatchState(self._state, inHigh, inLow, inClose)
		return a