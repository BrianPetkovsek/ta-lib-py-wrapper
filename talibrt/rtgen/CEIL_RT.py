import talibrt
from typing import List


class CEIL_RT:
	def __init__(self):
		self.res, self._state = talibrt.CEIL_StateInit()
	
	def __del__(self):
		self.res = talibrt.CEIL_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.CEIL_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.CEIL_BatchState(self._state, inReal)
		return a