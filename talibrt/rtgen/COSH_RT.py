import talibrt
from typing import List


class COSH_RT:
	def __init__(self):
		self.res, self._state = talibrt.COSH_StateInit()
	
	def __del__(self):
		self.res = talibrt.COSH_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.COSH_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.COSH_BatchState(self._state, inReal)
		return a