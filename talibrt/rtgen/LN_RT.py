import talibrt
from typing import List


class LN_RT:
	def __init__(self):
		self.res, self._state = talibrt.LN_StateInit()
	
	def __del__(self):
		self.res = talibrt.LN_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.LN_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.LN_BatchState(self._state, inReal)
		return a