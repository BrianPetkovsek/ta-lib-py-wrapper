import talibrt
from typing import List


class MAVP_RT:
	def __init__(self, optInMinPeriod: int, optInMaxPeriod: int, optInMAType: 'TA_MAType'):
		self.res, self._state = talibrt.MAVP_StateInit(optInMinPeriod, optInMaxPeriod, optInMAType)
	
	def __del__(self):
		self.res = talibrt.MAVP_StateFree(self._state)
	
	def state(self, inReal: float, inPeriods: float):
		self.res, *a = talibrt.MAVP_State(self._state, inReal, inPeriods)
		return a
	
	def batchState(self, inReal: List[float], inPeriods: List[float]):
		self.res, *a = talibrt.MAVP_BatchState(self._state, inReal, inPeriods)
		return a