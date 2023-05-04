import talibrt
from typing import List


class STDDEV_RT:
	def __init__(self, optInTimePeriod: int, optInNbDev: float):
		self.res, self._state = talibrt.STDDEV_StateInit(optInTimePeriod, optInNbDev)
	
	def __del__(self):
		self.res = talibrt.STDDEV_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.STDDEV_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.STDDEV_BatchState(self._state, inReal)
		return a