import talibrt
from typing import List


class LINEARREG_SLOPE_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.LINEARREG_SLOPE_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.LINEARREG_SLOPE_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.LINEARREG_SLOPE_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.LINEARREG_SLOPE_BatchState(self._state, inReal)
		return a