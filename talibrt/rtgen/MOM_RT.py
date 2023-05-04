import talibrt
from typing import List


class MOM_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.MOM_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.MOM_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.MOM_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.MOM_BatchState(self._state, inReal)
		return a