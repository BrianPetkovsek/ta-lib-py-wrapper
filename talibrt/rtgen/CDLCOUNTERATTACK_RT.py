import talibrt
from typing import List


class CDLCOUNTERATTACK_RT:
	def __init__(self):
		self.res, self._state = talibrt.CDLCOUNTERATTACK_StateInit()
	
	def __del__(self):
		self.res = talibrt.CDLCOUNTERATTACK_StateFree(self._state)
	
	def state(self, inOpen: float, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.CDLCOUNTERATTACK_State(self._state, inOpen, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inOpen: List[float], inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.CDLCOUNTERATTACK_BatchState(self._state, inOpen, inHigh, inLow, inClose)
		return a