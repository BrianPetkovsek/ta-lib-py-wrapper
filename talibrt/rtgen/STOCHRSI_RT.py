import talibrt
from typing import List


class STOCHRSI_RT:
	def __init__(self, optInTimePeriod: int, optInFastK_Period: int, optInFastD_Period: int, optInFastD_MAType: 'TA_MAType'):
		self.res, self._state = talibrt.STOCHRSI_StateInit(optInTimePeriod, optInFastK_Period, optInFastD_Period, optInFastD_MAType)
	
	def __del__(self):
		self.res = talibrt.STOCHRSI_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.STOCHRSI_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.STOCHRSI_BatchState(self._state, inReal)
		return a