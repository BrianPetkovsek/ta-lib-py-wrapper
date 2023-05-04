import talibrt
from typing import List


class TRIMA_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.TRIMA_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.TRIMA_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.TRIMA_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.TRIMA_BatchState(self._state, inReal)
		return a