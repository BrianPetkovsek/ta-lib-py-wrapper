import talibrt
from typing import List


class ROCR_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.ROCR_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.ROCR_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.ROCR_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.ROCR_BatchState(self._state, inReal)
		return a