import talibrt
from typing import List


class SINH_RT:
	def __init__(self):
		self.res, self._state = talibrt.SINH_StateInit()
	
	def __del__(self):
		self.res = talibrt.SINH_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.SINH_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.SINH_BatchState(self._state, inReal)
		return a