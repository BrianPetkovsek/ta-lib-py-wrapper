import talibrt
from typing import List


class AD_RT:
	def __init__(self):
		self.res, self._state = talibrt.AD_StateInit()
	
	def __del__(self):
		self.res = talibrt.AD_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float, inVolume: float):
		self.res, *a = talibrt.AD_State(self._state, inHigh, inLow, inClose, inVolume)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float], inVolume: List[float]):
		self.res, *a = talibrt.AD_BatchState(self._state, inHigh, inLow, inClose, inVolume)
		return a