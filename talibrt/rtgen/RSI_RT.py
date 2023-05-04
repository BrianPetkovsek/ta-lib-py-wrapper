import talibrt
from typing import List


class RSI_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.RSI_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.RSI_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.RSI_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.RSI_BatchState(self._state, inReal)
		return a