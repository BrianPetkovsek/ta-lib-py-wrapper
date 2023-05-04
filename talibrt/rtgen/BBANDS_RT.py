import talibrt
from typing import List


class BBANDS_RT:
	def __init__(self, optInTimePeriod: int, optInNbDevUp: float, optInNbDevDn: float, optInMAType: 'TA_MAType'):
		self.res, self._state = talibrt.BBANDS_StateInit(optInTimePeriod, optInNbDevUp, optInNbDevDn, optInMAType)
	
	def __del__(self):
		self.res = talibrt.BBANDS_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.BBANDS_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.BBANDS_BatchState(self._state, inReal)
		return a