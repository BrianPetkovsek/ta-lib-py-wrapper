import talibrt
from typing import List


class CDLEVENINGDOJISTAR_RT:
	def __init__(self, optInPenetration: float):
		self.res, self._state = talibrt.CDLEVENINGDOJISTAR_StateInit(optInPenetration)
	
	def __del__(self):
		self.res = talibrt.CDLEVENINGDOJISTAR_StateFree(self._state)
	
	def state(self, inOpen: float, inHigh: float, inLow: float, inClose: float):
		self.res, *a = talibrt.CDLEVENINGDOJISTAR_State(self._state, inOpen, inHigh, inLow, inClose)
		return a
	
	def batchState(self, inOpen: List[float], inHigh: List[float], inLow: List[float], inClose: List[float]):
		self.res, *a = talibrt.CDLEVENINGDOJISTAR_BatchState(self._state, inOpen, inHigh, inLow, inClose)
		return a