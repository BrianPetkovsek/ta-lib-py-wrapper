import talibrt
from typing import List


class PVI_RT:
	def __init__(self):
		self.res, self._state = talibrt.PVI_StateInit()
	
	def __del__(self):
		self.res = talibrt.PVI_StateFree(self._state)
	
	def state(self, inClose: float, inVolume: float):
		self.res, *a = talibrt.PVI_State(self._state, inClose, inVolume)
		return a
	
	def batchState(self, inClose: List[float], inVolume: List[float]):
		self.res, *a = talibrt.PVI_BatchState(self._state, inClose, inVolume)
		return a