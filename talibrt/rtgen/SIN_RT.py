import talibrt
from typing import List


class SIN_RT:
	def __init__(self):
		self.res, self._state = talibrt.SIN_StateInit()
	
	def __del__(self):
		self.res = talibrt.SIN_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.SIN_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.SIN_BatchState(self._state, inReal)
		return a