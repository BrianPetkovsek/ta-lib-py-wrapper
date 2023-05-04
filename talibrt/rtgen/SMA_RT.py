import talibrt
from typing import List


class SMA_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.SMA_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.SMA_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.SMA_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.SMA_BatchState(self._state, inReal)
		return a