import talibrt
from typing import List


class MININDEX_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.MININDEX_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.MININDEX_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MININDEX_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MININDEX_BatchState(self._state, inReal)
		return a