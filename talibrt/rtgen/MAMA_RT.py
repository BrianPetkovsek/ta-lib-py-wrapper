import talibrt
from typing import List


class MAMA_RT:
	def __init__(self, optInFastLimit: float, optInSlowLimit: float):
		self.res, self._state = talibrt.MAMA_StateInit(optInFastLimit, optInSlowLimit)
	
	def __del__(self):
		self.res = talibrt.MAMA_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MAMA_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MAMA_BatchState(self._state, inReal)
		return a