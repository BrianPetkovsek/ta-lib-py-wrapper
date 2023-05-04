import talibrt
from typing import List


class MAX_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.MAX_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.MAX_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MAX_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MAX_BatchState(self._state, inReal)
		return a