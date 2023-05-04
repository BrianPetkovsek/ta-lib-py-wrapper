import talibrt
from typing import List


class COS_RT:
	def __init__(self):
		self.res, self._state = talibrt.COS_StateInit()
	
	def __del__(self):
		self.res = talibrt.COS_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.COS_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.COS_BatchState(self._state, inReal)
		return a