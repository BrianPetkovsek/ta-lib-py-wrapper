import talibrt
from typing import List


class PVT_RT:
	def __init__(self):
		self.res, self._state = talibrt.PVT_StateInit()
	
	def __del__(self):
		self.res = talibrt.PVT_StateFree(self._state)
	
	def state(self, inClose: float, inVolume: float):
		self.res, *a = talibrt.PVT_State(self._state, inClose, inVolume)
		return a
	
	def batchState(self, inClose: List[float], inVolume: List[float]):
		self.res, *a = talibrt.PVT_BatchState(self._state, inClose, inVolume)
		return a