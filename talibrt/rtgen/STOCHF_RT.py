import talibrt
from typing import List


class STOCHF_RT:
	def __init__(self, optInFastK_Period: int, optInFastD_Period: int, optInFastD_MAType: 'TA_MAType'):
		self.res, self._state = talibrt.STOCHF_StateInit(optInFastK_Period, optInFastD_Period, optInFastD_MAType)
	
	def __del__(self):
		self.res = talibrt.STOCHF_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.STOCHF_State(self._state, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.STOCHF_BatchState(self._state, inHigh, inLow, inClose)
		return a