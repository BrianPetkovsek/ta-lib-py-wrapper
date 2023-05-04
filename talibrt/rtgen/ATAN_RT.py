import talibrt
from typing import List


class ATAN_RT:
	def __init__(self):
		self.res, self._state = talibrt.ATAN_StateInit()
	
	def __del__(self):
		self.res = talibrt.ATAN_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.ATAN_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.ATAN_BatchState(self._state, inReal)
		return a