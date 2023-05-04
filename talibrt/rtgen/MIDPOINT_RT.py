import talibrt
from typing import List


class MIDPOINT_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.MIDPOINT_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.MIDPOINT_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MIDPOINT_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MIDPOINT_BatchState(self._state, inReal)
		return a