import talibrt
from typing import List


class STOCH_RT:
	def __init__(self, optInFastK_Period: int, optInSlowK_Period: int, optInSlowK_MAType: 'TA_MAType', optInSlowD_Period: int, optInSlowD_MAType: 'TA_MAType'):
		self.res, self._state = talibrt.STOCH_StateInit(optInFastK_Period, optInSlowK_Period, optInSlowK_MAType, optInSlowD_Period, optInSlowD_MAType)
	
	def __del__(self):
		self.res = talibrt.STOCH_StateFree(self._state)
	
	def state(self, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.STOCH_State(self._state, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.STOCH_BatchState(self._state, inHigh, inLow, inClose)
		return a