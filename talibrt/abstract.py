import talibrt._ta_lib as _ta_lib
from ._ta_lib import Function as _Function, FunctionRT as _FunctionRT, __TA_FUNCTION_NAMES__, _get_defaults_and_docs

# add some backwards compat for backtrader
from ._ta_lib import TA_FUNC_FLAGS, TA_INPUT_FLAGS, TA_OUTPUT_FLAGS

_func_obj_mapping = {
    func_name: {
        getattr(_ta_lib, func_name),
        getattr(_ta_lib, func_name + "_State"),
        getattr(_ta_lib, func_name + "_StateInit"),
        getattr(_ta_lib, func_name + "_StateFree"),
        getattr(_ta_lib, func_name + "_StateSave"),
        getattr(_ta_lib, func_name + "_StateLoad")
    }
    for func_name in __TA_FUNCTION_NAMES__
}


def Function(function_name, *args, **kwargs):
    func_name = function_name.upper()
    if func_name not in _func_obj_mapping:
        raise Exception('%s not supported by TA-LIB-RT.' % func_name)

    return _Function(
        func_name, _func_obj_mapping[func_name][0], *args, **kwargs
    )

def FunctionRT(function_name, *args, **kwargs):
    func_name = function_name.upper()
    if func_name not in _func_obj_mapping:
        raise Exception('%s not supported by TA-LIB-RT.' % func_name)

    func_list = _func_obj_mapping[func_name]
    return _FunctionRT(
        func_name, func_list[1], func_list[2], func_list[3], func_list[4], func_list[5], *args, **kwargs
    )

for func_name in __TA_FUNCTION_NAMES__:
    globals()[func_name] = Function(func_name)
    globals()[func_name+"_RT"] = FunctionRT(func_name)

__all__ = ["Function", "_get_defaults_and_docs"] + __TA_FUNCTION_NAMES__
