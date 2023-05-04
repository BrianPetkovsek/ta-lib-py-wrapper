import talibrt
from typing import List


class ROCP_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.ROCP_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.ROCP_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.ROCP_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.ROCP_BatchState(self._state, inReal)
		return a