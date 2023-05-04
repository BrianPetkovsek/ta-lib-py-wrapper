import talibrt
from typing import List


class TRIX_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.TRIX_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.TRIX_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.TRIX_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.TRIX_BatchState(self._state, inReal)
		return a