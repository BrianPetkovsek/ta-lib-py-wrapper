import talibrt
from typing import List


class MFI_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.MFI_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.MFI_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float, inVolume: float):
		self.res, *a = talibrt.MFI_State(self._state, inHigh, inLow, inClose, inVolume)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float], inVolume: List[float]):
		self.res, *a = talibrt.MFI_BatchState(self._state, inHigh, inLow, inClose, inVolume)
		return a