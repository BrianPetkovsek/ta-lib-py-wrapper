import talibrt
from typing import List


class APO_RT:
	def __init__(self, optInFastPeriod: int, optInSlowPeriod: int, optInMAType: 'TA_MAType'):
		self.res, self._state = talibrt.APO_StateInit(optInFastPeriod, optInSlowPeriod, optInMAType)
	
	def __del__(self):
		self.res = talibrt.APO_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.APO_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.APO_BatchState(self._state, inReal)
		return a