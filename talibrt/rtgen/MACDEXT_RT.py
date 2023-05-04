import talibrt
from typing import List


class MACDEXT_RT:
	def __init__(self, optInFastPeriod: int, optInFastMAType: 'TA_MAType', optInSlowPeriod: int, optInSlowMAType: 'TA_MAType', optInSignalPeriod: int, optInSignalMAType: 'TA_MAType'):
		self.res, self._state = talibrt.MACDEXT_StateInit(optInFastPeriod, optInFastMAType, optInSlowPeriod, optInSlowMAType, optInSignalPeriod, optInSignalMAType)
	
	def __del__(self):
		self.res = talibrt.MACDEXT_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MACDEXT_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MACDEXT_BatchState(self._state, inReal)
		return a