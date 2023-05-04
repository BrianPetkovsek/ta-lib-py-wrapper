import talibrt
from typing import List


class IMI_RT:
	def __init__(self, optInTimePeriod: int):
		self.res, self._state = talibrt.IMI_StateInit(optInTimePeriod)
	
	def __del__(self):
		self.res = talibrt.IMI_StateFree(self._state)
	
	def state(self, inOpen: float, inClose: float):
		self.res, *a = talibrt.IMI_State(self._state, inOpen, inClose)
		return a
	
	def batchState(self, inOpen: List[float], inClose: List[float]):
		self.res, *a = talibrt.IMI_BatchState(self._state, inOpen, inClose)
		return a