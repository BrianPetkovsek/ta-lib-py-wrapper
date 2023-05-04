import talibrt
from typing import List


class HT_DCPHASE_RT:
	def __init__(self):
		self.res, self._state = talibrt.HT_DCPHASE_StateInit()
	
	def __del__(self):
		self.res = talibrt.HT_DCPHASE_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.HT_DCPHASE_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.HT_DCPHASE_BatchState(self._state, inReal)
		return a