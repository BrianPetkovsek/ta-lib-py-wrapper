import talibrt
from typing import List


class TEMA_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.TEMA_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.TEMA_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.TEMA_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.TEMA_BatchState(self._state, inReal)
		return a