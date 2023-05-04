import talibrt
from typing import List


class TANH_RT:
	def __init__(self):
		self.res, self._state = talibrt.TANH_StateInit()
	
	def __del__(self):
		self.res = talibrt.TANH_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.TANH_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.TANH_BatchState(self._state, inReal)
		return a