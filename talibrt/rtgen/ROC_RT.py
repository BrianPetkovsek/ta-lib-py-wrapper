import talibrt
from typing import List


class ROC_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.ROC_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.ROC_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.ROC_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.ROC_BatchState(self._state, inReal)
		return a