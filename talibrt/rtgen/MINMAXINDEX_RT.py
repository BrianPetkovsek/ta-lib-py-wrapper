import talibrt
from typing import List


class MINMAXINDEX_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.MINMAXINDEX_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.MINMAXINDEX_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MINMAXINDEX_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MINMAXINDEX_BatchState(self._state, inReal)
		return a