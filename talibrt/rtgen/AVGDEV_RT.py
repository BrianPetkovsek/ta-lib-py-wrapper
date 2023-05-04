import talibrt
from typing import List


class AVGDEV_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.AVGDEV_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.AVGDEV_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.AVGDEV_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.AVGDEV_BatchState(self._state, inReal)
		return a