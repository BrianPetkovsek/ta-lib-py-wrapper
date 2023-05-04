import talibrt
from typing import List


class SQRT_RT:
	def __init__(self):
		self.res, self._state = talibrt.SQRT_StateInit()
	
	def __del__(self):
		self.res = talibrt.SQRT_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.SQRT_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.SQRT_BatchState(self._state, inReal)
		return a