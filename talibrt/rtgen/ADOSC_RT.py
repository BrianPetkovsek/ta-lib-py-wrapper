import talibrt
from typing import List


class ADOSC_RT:
	def __init__(self, optInFastPeriod: int, optInSlowPeriod: int):
		self.res, self._state = talibrt.ADOSC_StateInit(optInFastPeriod, optInSlowPeriod)
	
	def __del__(self):
		self.res = talibrt.ADOSC_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float, inVolume: float):
		self.res, *a = talibrt.ADOSC_State(self._state, inHigh, inLow, inClose, inVolume)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float], inVolume: List[float]):
		self.res, *a = talibrt.ADOSC_BatchState(self._state, inHigh, inLow, inClose, inVolume)
		return a