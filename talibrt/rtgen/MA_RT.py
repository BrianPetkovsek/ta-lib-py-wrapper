import talibrt
from typing import List


class MA_RT:
	def __init__(self, optInTimePeriod: int, optInMAType: 'TA_MAType'):
		self.res, self._state = talibrt.MA_StateInit(optInTimePeriod, optInMAType)
	
	def __del__(self):
		self.res = talibrt.MA_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MA_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MA_BatchState(self._state, inReal)
		return a