import talibrt
from typing import List


class TSF_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.TSF_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.TSF_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.TSF_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.TSF_BatchState(self._state, inReal)
		return a