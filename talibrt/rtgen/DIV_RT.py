import talibrt
from typing import List


class DIV_RT:
	def __init__(self):
		self.res, self._state = talibrt.DIV_StateInit()
	
	def __del__(self):
		self.res = talibrt.DIV_StateFree(self._state)
	
	def state(self, inReal0: float, inReal1: float):
		self.res, *a = talibrt.DIV_State(self._state, inReal0, inReal1)
		return a
	
	def batchState(self, inReal0: List[float], inReal1: List[float]):
		self.res, *a = talibrt.DIV_BatchState(self._state, inReal0, inReal1)
		return a