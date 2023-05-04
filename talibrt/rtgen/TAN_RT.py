import talibrt
from typing import List


class TAN_RT:
	def __init__(self):
		self.res, self._state = talibrt.TAN_StateInit()
	
	def __del__(self):
		self.res = talibrt.TAN_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.TAN_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.TAN_BatchState(self._state, inReal)
		return a