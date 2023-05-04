import talibrt
from typing import List


class VAR_RT:
	def __init__(self, optInTimePeriod: int, optInNbDev: float):
		self.res, self._state = talibrt.VAR_StateInit(optInTimePeriod, optInNbDev)
	
	def __del__(self):
		self.res = talibrt.VAR_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.VAR_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.VAR_BatchState(self._state, inReal)
		return a