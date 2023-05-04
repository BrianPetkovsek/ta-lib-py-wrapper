import talibrt
from typing import List


class EXP_RT:
	def __init__(self):
		self.res, self._state = talibrt.EXP_StateInit()
	
	def __del__(self):
		self.res = talibrt.EXP_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.EXP_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.EXP_BatchState(self._state, inReal)
		return a