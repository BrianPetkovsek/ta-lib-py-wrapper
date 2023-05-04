import talibrt
from typing import List


class FLOOR_RT:
	def __init__(self):
		self.res, self._state = talibrt.FLOOR_StateInit()
	
	def __del__(self):
		self.res = talibrt.FLOOR_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.FLOOR_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.FLOOR_BatchState(self._state, inReal)
		return a