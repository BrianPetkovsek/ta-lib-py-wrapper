import talibrt
from typing import List


class ACOS_RT:
	def __init__(self):
		self.res, self._state = talibrt.ACOS_StateInit()
	
	def __del__(self):
		self.res = talibrt.ACOS_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.ACOS_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.ACOS_BatchState(self._state, inReal)
		return a