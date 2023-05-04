import talibrt
from typing import List


class PPO_RT:
	def __init__(self, optInFastPeriod: int, optInSlowPeriod: int, optInMAType: 'TA_MAType'):
		self.res, self._state = talibrt.PPO_StateInit(optInFastPeriod, optInSlowPeriod, optInMAType)
	
	def __del__(self):
		self.res = talibrt.PPO_StateFree(self._state)
	
	def state(self, inReal: float):
		self.res, *a = talibrt.PPO_State(self._state, inReal)
		return a
	
	def batchState(self, inReal: List[float]):
		self.res, *a = talibrt.PPO_BatchState(self._state, inReal)
		return a