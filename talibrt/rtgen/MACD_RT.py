import talibrt
from typing import List


class MACD_RT:
	def __init__(self, optInFastPeriod: int, optInSlowPeriod: int, optInSignalPeriod: int):
		self.res, self._state = talibrt.MACD_StateInit(optInFastPeriod, optInSlowPeriod, optInSignalPeriod)
	
	def __del__(self):
		self.res = talibrt.MACD_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MACD_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MACD_BatchState(self._state, inReal)
		return a