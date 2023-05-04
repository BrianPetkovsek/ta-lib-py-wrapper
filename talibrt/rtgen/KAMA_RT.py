import talibrt
from typing import List


class KAMA_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.KAMA_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.KAMA_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.KAMA_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.KAMA_BatchState(self._state, inReal)
		return a