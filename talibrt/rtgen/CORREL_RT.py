import talibrt
from typing import List


class CORREL_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.CORREL_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.CORREL_StateFree(self._state)
	
	def state(self, inReal0: float, inReal1: float):
		self.res, *a = talibrt.CORREL_State(self._state, inReal0, inReal1)
		return a
	
	def batchState(self, inReal0: List[float], inReal1: List[float]):
		self.res, *a = talibrt.CORREL_BatchState(self._state, inReal0, inReal1)
		return a