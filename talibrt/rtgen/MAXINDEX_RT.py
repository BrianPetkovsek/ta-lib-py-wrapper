import talibrt
from typing import List


class MAXINDEX_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.MAXINDEX_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.MAXINDEX_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MAXINDEX_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MAXINDEX_BatchState(self._state, inReal)
		return a