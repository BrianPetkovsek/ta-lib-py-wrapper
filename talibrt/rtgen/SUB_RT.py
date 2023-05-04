import talibrt
from typing import List


class SUB_RT:
	def __init__(self):
		self.res, self._state = talibrt.SUB_StateInit()
	
	def __del__(self):
		self.res = talibrt.SUB_StateFree(self._state)
	
	def state(self, inReal0: float, inReal1: float):
		self.res, *a = talibrt.SUB_State(self._state, inReal0, inReal1)
		return a
	
	def batchState(self, inReal0: List[float], inReal1: List[float]):
		self.res, *a = talibrt.SUB_BatchState(self._state, inReal0, inReal1)
		return a