import talibrt
from typing import List


class MIN_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.MIN_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.MIN_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MIN_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MIN_BatchState(self._state, inReal)
		return a