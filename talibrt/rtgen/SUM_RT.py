import talibrt
from typing import List


class SUM_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.SUM_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.SUM_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.SUM_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.SUM_BatchState(self._state, inReal)
		return a