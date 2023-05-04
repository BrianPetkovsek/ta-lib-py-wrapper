import talibrt
from typing import List


class OBV_RT:
	def __init__(self):
		self.res, self._state = talibrt.OBV_StateInit()
	
	def __del__(self):
		self.res = talibrt.OBV_StateFree(self._state)
	
	def state(self, inClose: float, inVolume: float):
		self.res, *a = talibrt.OBV_State(self._state, inClose, inVolume)
		return a
	
	def batchState(self, inClose: List[float], inVolume: List[float]):
		self.res, *a = talibrt.OBV_BatchState(self._state, inClose, inVolume)
		return a