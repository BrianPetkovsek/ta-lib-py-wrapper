import talibrt
from typing import List


class MACDFIX_RT:
	def __init__(self, optInSignalPeriod: int):
		self.res, self._state = talibrt.MACDFIX_StateInit(optInSignalPeriod)
	
	def __del__(self):
		self.res = talibrt.MACDFIX_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MACDFIX_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MACDFIX_BatchState(self._state, inReal)
		return a