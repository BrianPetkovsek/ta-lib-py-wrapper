import talibrt
from typing import List


class DEMA_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.DEMA_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.DEMA_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.DEMA_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.DEMA_BatchState(self._state, inReal)
		return a