import talibrt
from typing import List


class WMA_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.WMA_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.WMA_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.WMA_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.WMA_BatchState(self._state, inReal)
		return a