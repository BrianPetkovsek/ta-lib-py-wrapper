import talibrt
from typing import List


class WLMA_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.WLMA_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.WLMA_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.WLMA_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.WLMA_BatchState(self._state, inReal)
		return a