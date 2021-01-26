from cpython.ref cimport PyObject
cimport numpy as np
from numpy import nan
from cython import boundscheck, wraparound
#from cpython.pycapsule cimport PyCapsule_New, PyCapsule_IsValid, PyCapsule_GetPointer, PyCapsule_Destructor

# _ta_check_success: defined in _common.pxi

from enum import Enum
class TALibResult(Enum):
    OK = 0
    LIB_NOT_INITIALIZED = 1
    BAD_PARAM = 2
    ALLOC_ERR = 3
    GROUP_NOT_FOUND = 4
    FUNC_NOT_FOUND = 5
    INVALID_HANDLE = 6
    INVALID_PARAM_HOLDER = 7
    INVALID_PARAM_HOLDER_TYPE = 8
    INVALID_PARAM_FUNCTION = 9
    INPUT_NOT_ALL_INITIALIZE = 10
    OUTPUT_NOT_ALL_INITIALIZE = 11
    OUT_OF_RANGE_START_INDEX = 12
    OUT_OF_RANGE_END_INDEX = 13
    INVALID_LIST_TYPE = 14
    BAD_OBJECT = 15
    NOT_SUPPORTED = 16
    NEED_MORE_DATA = 17
    IO_FAILED = 18
    INTERNAL_ERROR = 5000
    UNKNOWN_ERR = 65535

cdef double NaN = nan

cdef extern from "numpy/arrayobject.h":
    int PyArray_TYPE(np.ndarray)
    np.ndarray PyArray_EMPTY(int, np.npy_intp*, int, int)
    int PyArray_FLAGS(np.ndarray)
    np.ndarray PyArray_GETCONTIGUOUS(np.ndarray)

np.import_array() # Initialize the NumPy C API

cimport talibrt._ta_lib as lib
from talibrt._ta_lib cimport TA_RetCode

cdef np.ndarray check_array(np.ndarray real):
    if PyArray_TYPE(real) != np.NPY_DOUBLE:
        raise Exception("input array type is not double")
    if real.ndim != 1:
        raise Exception("input array has wrong dimensions")
    if not (PyArray_FLAGS(real) & np.NPY_C_CONTIGUOUS):
        real = PyArray_GETCONTIGUOUS(real)
    return real

cdef np.npy_intp check_length2(np.ndarray a1, np.ndarray a2) except -1:
    cdef:
        np.npy_intp length
    length = a1.shape[0]
    if length != a2.shape[0]:
        raise Exception("input array lengths are different")
    return length

cdef np.npy_intp check_length3(np.ndarray a1, np.ndarray a2, np.ndarray a3) except -1:
    cdef:
        np.npy_intp length
    length = a1.shape[0]
    if length != a2.shape[0]:
        raise Exception("input array lengths are different")
    if length != a3.shape[0]:
        raise Exception("input array lengths are different")
    return length

cdef np.npy_intp check_length4(np.ndarray a1, np.ndarray a2, np.ndarray a3, np.ndarray a4) except -1:
    cdef:
        np.npy_intp length
    length = a1.shape[0]
    if length != a2.shape[0]:
        raise Exception("input array lengths are different")
    if length != a3.shape[0]:
        raise Exception("input array lengths are different")
    if length != a4.shape[0]:
        raise Exception("input array lengths are different")
    return length

cdef np.npy_int check_begidx1(np.npy_intp length, double* a1) except -1:
    cdef:
        double val
    for i from 0 <= i < length:
        val = a1[i]
        if val != val:
            continue
        return i
    else:
        raise Exception("inputs are all NaN")

cdef np.npy_int check_begidx2(np.npy_intp length, double* a1, double* a2) except -1:
    cdef:
        double val
    for i from 0 <= i < length:
        val = a1[i]
        if val != val:
            continue
        val = a2[i]
        if val != val:
            continue
        return i
    else:
        raise Exception("inputs are all NaN")

cdef np.npy_int check_begidx3(np.npy_intp length, double* a1, double* a2, double* a3) except -1:
    cdef:
        double val
    for i from 0 <= i < length:
        val = a1[i]
        if val != val:
            continue
        val = a2[i]
        if val != val:
            continue
        val = a3[i]
        if val != val:
            continue
        return i
    else:
        raise Exception("inputs are all NaN")

cdef np.npy_int check_begidx4(np.npy_intp length, double* a1, double* a2, double* a3, double* a4) except -1:
    cdef:
        double val
    for i from 0 <= i < length:
        val = a1[i]
        if val != val:
            continue
        val = a2[i]
        if val != val:
            continue
        val = a3[i]
        if val != val:
            continue
        val = a4[i]
        if val != val:
            continue
        return i
    else:
        raise Exception("inputs are all NaN")

cdef np.ndarray make_double_array(np.npy_intp length, int lookback):
    cdef:
        np.ndarray outreal
        double* outreal_data
    outreal = PyArray_EMPTY(1, &length, np.NPY_DOUBLE, np.NPY_DEFAULT)
    outreal_data = <double*>outreal.data
    for i from 0 <= i < min(lookback, length):
        outreal_data[i] = NaN
    return outreal

cdef np.ndarray make_int_array(np.npy_intp length, int lookback):
    cdef:
        np.ndarray outinteger
        int* outinteger_data
    outinteger = PyArray_EMPTY(1, &length, np.NPY_INT32, np.NPY_DEFAULT)
    outinteger_data = <int*>outinteger.data
    for i from 0 <= i < min(lookback, length):
        outinteger_data[i] = 0
    return outinteger


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACCBANDS( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ ACCBANDS(high, low, close[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outrealupperband
        np.ndarray outrealmiddleband
        np.ndarray outreallowerband
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ACCBANDS_Lookback( timeperiod )
    outrealupperband = make_double_array(length, lookback)
    outrealmiddleband = make_double_array(length, lookback)
    outreallowerband = make_double_array(length, lookback)
    retCode = lib.TA_ACCBANDS( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outrealupperband.data)+lookback , <double *>(outrealmiddleband.data)+lookback , <double *>(outreallowerband.data)+lookback )
    _ta_check_success("TA_ACCBANDS", retCode)
    return TALibResult(retCode), outrealupperband , outrealmiddleband , outreallowerband 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACCBANDS_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ACCBANDS_StateInit(& _state, timeperiod)
    _ta_check_success("TA_ACCBANDS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACCBANDS_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outrealupperband
        double outrealmiddleband
        double outreallowerband
    _state = <void*>state
    retCode = lib.TA_ACCBANDS_State( _state , high , low , close , &outrealupperband , &outrealmiddleband , &outreallowerband )
    need_mode_data = not _ta_check_success("TA_ACCBANDS_State", retCode)
    return TALibResult(retCode), outrealupperband , outrealmiddleband , outreallowerband 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACCBANDS_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ ACCBANDS_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outrealupperband
        np.ndarray outrealmiddleband
        np.ndarray outreallowerband
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outrealupperband = make_double_array(length, lookback)
    outrealmiddleband = make_double_array(length, lookback)
    outreallowerband = make_double_array(length, lookback)
    retCode = lib.TA_ACCBANDS_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outrealupperband.data)+lookback , <double *>(outrealmiddleband.data)+lookback , <double *>(outreallowerband.data)+lookback )
    _ta_check_success("TA_ACCBANDS_BatchState", retCode)
    return TALibResult(retCode), outrealupperband , outrealmiddleband , outreallowerband 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACCBANDS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ACCBANDS_StateFree( & _state )
    _ta_check_success("TA_ACCBANDS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACCBANDS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ACCBANDS"
    _state = <void*> state
    retCode = lib.TA_ACCBANDS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ACCBANDS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACCBANDS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ACCBANDS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ACCBANDS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACOS( np.ndarray real not None ):
    """ ACOS(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ACOS_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ACOS( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ACOS", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACOS_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ACOS_StateInit(& _state)
    _ta_check_success("TA_ACOS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACOS_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ACOS_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_ACOS_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACOS_BatchState( size_t state , np.ndarray real not None ):
    """ ACOS_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ACOS_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ACOS_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACOS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ACOS_StateFree( & _state )
    _ta_check_success("TA_ACOS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACOS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ACOS"
    _state = <void*> state
    retCode = lib.TA_ACOS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ACOS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ACOS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ACOS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ACOS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AD( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , np.ndarray volume not None ):
    """ AD(high, low, close, volume)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    volume = check_array(volume)
    length = check_length4(high, low, close, volume)
    begidx = check_begidx4(length, <double*>(high.data), <double*>(low.data), <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_AD_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_AD( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_AD", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AD_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_AD_StateInit(& _state)
    _ta_check_success("TA_AD_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AD_State( size_t state , double high , double low , double close , double volume ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_AD_State( _state , high , low , close , volume , &outreal )
    need_mode_data = not _ta_check_success("TA_AD_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AD_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , np.ndarray volume not None ):
    """ AD_BatchState(high, low, close, volume)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    volume = check_array(volume)
    length = check_length4(high, low, close, volume)
    begidx = check_begidx4(length, <double*>(high.data), <double*>(low.data), <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_AD_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_AD_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AD_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_AD_StateFree( & _state )
    _ta_check_success("TA_AD_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AD_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "AD"
    _state = <void*> state
    retCode = lib.TA_AD_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_AD_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AD_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_AD_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_AD_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADD( np.ndarray real0 not None , np.ndarray real1 not None ):
    """ ADD(real0, real1)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ADD_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ADD( 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ADD", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADD_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ADD_StateInit(& _state)
    _ta_check_success("TA_ADD_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADD_State( size_t state , double real0 , double real1 ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ADD_State( _state , real0 , real1 , &outreal )
    need_mode_data = not _ta_check_success("TA_ADD_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADD_BatchState( size_t state , np.ndarray real0 not None , np.ndarray real1 not None ):
    """ ADD_BatchState(real0, real1)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ADD_BatchState( _state , 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ADD_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADD_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ADD_StateFree( & _state )
    _ta_check_success("TA_ADD_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADD_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ADD"
    _state = <void*> state
    retCode = lib.TA_ADD_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ADD_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADD_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ADD_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ADD_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADOSC( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , np.ndarray volume not None , int fastperiod=-2**31 , int slowperiod=-2**31 ):
    """ ADOSC(high, low, close, volume[, fastperiod=?, slowperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    volume = check_array(volume)
    length = check_length4(high, low, close, volume)
    begidx = check_begidx4(length, <double*>(high.data), <double*>(low.data), <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ADOSC_Lookback( fastperiod , slowperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ADOSC( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , fastperiod , slowperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ADOSC", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADOSC_StateInit( int fastperiod=-2**31 , int slowperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ADOSC_StateInit(& _state, fastperiod, slowperiod)
    _ta_check_success("TA_ADOSC_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADOSC_State( size_t state , double high , double low , double close , double volume ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ADOSC_State( _state , high , low , close , volume , &outreal )
    need_mode_data = not _ta_check_success("TA_ADOSC_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADOSC_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , np.ndarray volume not None ):
    """ ADOSC_BatchState(high, low, close, volume)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    volume = check_array(volume)
    length = check_length4(high, low, close, volume)
    begidx = check_begidx4(length, <double*>(high.data), <double*>(low.data), <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ADOSC_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ADOSC_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADOSC_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ADOSC_StateFree( & _state )
    _ta_check_success("TA_ADOSC_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADOSC_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ADOSC"
    _state = <void*> state
    retCode = lib.TA_ADOSC_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ADOSC_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADOSC_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ADOSC_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ADOSC_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADX( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ ADX(high, low, close[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ADX_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ADX( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ADX", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADX_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ADX_StateInit(& _state, timeperiod)
    _ta_check_success("TA_ADX_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADX_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ADX_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_ADX_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADX_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ ADX_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ADX_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ADX_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADX_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ADX_StateFree( & _state )
    _ta_check_success("TA_ADX_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADX_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ADX"
    _state = <void*> state
    retCode = lib.TA_ADX_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ADX_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADX_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ADX_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ADX_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADXR( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ ADXR(high, low, close[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ADXR_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ADXR( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ADXR", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADXR_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ADXR_StateInit(& _state, timeperiod)
    _ta_check_success("TA_ADXR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADXR_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ADXR_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_ADXR_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADXR_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ ADXR_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ADXR_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ADXR_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADXR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ADXR_StateFree( & _state )
    _ta_check_success("TA_ADXR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADXR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ADXR"
    _state = <void*> state
    retCode = lib.TA_ADXR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ADXR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ADXR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ADXR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ADXR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def APO( np.ndarray real not None , int fastperiod=-2**31 , int slowperiod=-2**31 , int matype=0 ):
    """ APO(real[, fastperiod=?, slowperiod=?, matype=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_APO_Lookback( fastperiod , slowperiod , matype )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_APO( 0 , endidx , <double *>(real.data)+begidx , fastperiod , slowperiod , matype , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_APO", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def APO_StateInit( int fastperiod=-2**31 , int slowperiod=-2**31 , int matype=0 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_APO_StateInit(& _state, fastperiod, slowperiod, matype)
    _ta_check_success("TA_APO_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def APO_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_APO_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_APO_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def APO_BatchState( size_t state , np.ndarray real not None ):
    """ APO_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_APO_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_APO_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def APO_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_APO_StateFree( & _state )
    _ta_check_success("TA_APO_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def APO_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "APO"
    _state = <void*> state
    retCode = lib.TA_APO_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_APO_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def APO_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_APO_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_APO_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROON( np.ndarray high not None , np.ndarray low not None , int timeperiod=-2**31 ):
    """ AROON(high, low[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outaroondown
        np.ndarray outaroonup
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_AROON_Lookback( timeperiod )
    outaroondown = make_double_array(length, lookback)
    outaroonup = make_double_array(length, lookback)
    retCode = lib.TA_AROON( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outaroondown.data)+lookback , <double *>(outaroonup.data)+lookback )
    _ta_check_success("TA_AROON", retCode)
    return TALibResult(retCode), outaroondown , outaroonup 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROON_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_AROON_StateInit(& _state, timeperiod)
    _ta_check_success("TA_AROON_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROON_State( size_t state , double high , double low ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outaroondown
        double outaroonup
    _state = <void*>state
    retCode = lib.TA_AROON_State( _state , high , low , &outaroondown , &outaroonup )
    need_mode_data = not _ta_check_success("TA_AROON_State", retCode)
    return TALibResult(retCode), outaroondown , outaroonup 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROON_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None ):
    """ AROON_BatchState(high, low)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outaroondown
        np.ndarray outaroonup
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outaroondown = make_double_array(length, lookback)
    outaroonup = make_double_array(length, lookback)
    retCode = lib.TA_AROON_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , &outbegidx , &outnbelement , <double *>(outaroondown.data)+lookback , <double *>(outaroonup.data)+lookback )
    _ta_check_success("TA_AROON_BatchState", retCode)
    return TALibResult(retCode), outaroondown , outaroonup 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROON_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_AROON_StateFree( & _state )
    _ta_check_success("TA_AROON_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROON_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "AROON"
    _state = <void*> state
    retCode = lib.TA_AROON_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_AROON_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROON_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_AROON_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_AROON_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROONOSC( np.ndarray high not None , np.ndarray low not None , int timeperiod=-2**31 ):
    """ AROONOSC(high, low[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_AROONOSC_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_AROONOSC( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_AROONOSC", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROONOSC_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_AROONOSC_StateInit(& _state, timeperiod)
    _ta_check_success("TA_AROONOSC_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROONOSC_State( size_t state , double high , double low ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_AROONOSC_State( _state , high , low , &outreal )
    need_mode_data = not _ta_check_success("TA_AROONOSC_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROONOSC_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None ):
    """ AROONOSC_BatchState(high, low)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_AROONOSC_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_AROONOSC_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROONOSC_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_AROONOSC_StateFree( & _state )
    _ta_check_success("TA_AROONOSC_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROONOSC_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "AROONOSC"
    _state = <void*> state
    retCode = lib.TA_AROONOSC_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_AROONOSC_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AROONOSC_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_AROONOSC_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_AROONOSC_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ASIN( np.ndarray real not None ):
    """ ASIN(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ASIN_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ASIN( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ASIN", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ASIN_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ASIN_StateInit(& _state)
    _ta_check_success("TA_ASIN_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ASIN_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ASIN_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_ASIN_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ASIN_BatchState( size_t state , np.ndarray real not None ):
    """ ASIN_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ASIN_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ASIN_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ASIN_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ASIN_StateFree( & _state )
    _ta_check_success("TA_ASIN_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ASIN_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ASIN"
    _state = <void*> state
    retCode = lib.TA_ASIN_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ASIN_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ASIN_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ASIN_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ASIN_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATAN( np.ndarray real not None ):
    """ ATAN(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ATAN_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ATAN( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ATAN", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATAN_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ATAN_StateInit(& _state)
    _ta_check_success("TA_ATAN_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATAN_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ATAN_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_ATAN_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATAN_BatchState( size_t state , np.ndarray real not None ):
    """ ATAN_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ATAN_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ATAN_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATAN_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ATAN_StateFree( & _state )
    _ta_check_success("TA_ATAN_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATAN_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ATAN"
    _state = <void*> state
    retCode = lib.TA_ATAN_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ATAN_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATAN_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ATAN_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ATAN_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATR( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ ATR(high, low, close[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ATR_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ATR( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ATR", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATR_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ATR_StateInit(& _state, timeperiod)
    _ta_check_success("TA_ATR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATR_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ATR_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_ATR_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATR_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ ATR_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ATR_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ATR_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ATR_StateFree( & _state )
    _ta_check_success("TA_ATR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ATR"
    _state = <void*> state
    retCode = lib.TA_ATR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ATR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ATR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ATR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ATR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGPRICE( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ AVGPRICE(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_AVGPRICE_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_AVGPRICE( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_AVGPRICE", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGPRICE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_AVGPRICE_StateInit(& _state)
    _ta_check_success("TA_AVGPRICE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGPRICE_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_AVGPRICE_State( _state , open , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_AVGPRICE_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGPRICE_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ AVGPRICE_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_AVGPRICE_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_AVGPRICE_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGPRICE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_AVGPRICE_StateFree( & _state )
    _ta_check_success("TA_AVGPRICE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGPRICE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "AVGPRICE"
    _state = <void*> state
    retCode = lib.TA_AVGPRICE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_AVGPRICE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGPRICE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_AVGPRICE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_AVGPRICE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGDEV( np.ndarray real not None , int timeperiod=-2**31 ):
    """ AVGDEV(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_AVGDEV_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_AVGDEV( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_AVGDEV", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGDEV_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_AVGDEV_StateInit(& _state, timeperiod)
    _ta_check_success("TA_AVGDEV_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGDEV_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_AVGDEV_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_AVGDEV_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGDEV_BatchState( size_t state , np.ndarray real not None ):
    """ AVGDEV_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_AVGDEV_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_AVGDEV_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGDEV_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_AVGDEV_StateFree( & _state )
    _ta_check_success("TA_AVGDEV_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGDEV_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "AVGDEV"
    _state = <void*> state
    retCode = lib.TA_AVGDEV_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_AVGDEV_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def AVGDEV_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_AVGDEV_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_AVGDEV_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BBANDS( np.ndarray real not None , int timeperiod=-2**31 , double nbdevup=-4e37 , double nbdevdn=-4e37 , int matype=0 ):
    """ BBANDS(real[, timeperiod=?, nbdevup=?, nbdevdn=?, matype=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outrealupperband
        np.ndarray outrealmiddleband
        np.ndarray outreallowerband
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_BBANDS_Lookback( timeperiod , nbdevup , nbdevdn , matype )
    outrealupperband = make_double_array(length, lookback)
    outrealmiddleband = make_double_array(length, lookback)
    outreallowerband = make_double_array(length, lookback)
    retCode = lib.TA_BBANDS( 0 , endidx , <double *>(real.data)+begidx , timeperiod , nbdevup , nbdevdn , matype , &outbegidx , &outnbelement , <double *>(outrealupperband.data)+lookback , <double *>(outrealmiddleband.data)+lookback , <double *>(outreallowerband.data)+lookback )
    _ta_check_success("TA_BBANDS", retCode)
    return TALibResult(retCode), outrealupperband , outrealmiddleband , outreallowerband 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BBANDS_StateInit( int timeperiod=-2**31 , double nbdevup=-4e37 , double nbdevdn=-4e37 , int matype=0 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_BBANDS_StateInit(& _state, timeperiod, nbdevup, nbdevdn, matype)
    _ta_check_success("TA_BBANDS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BBANDS_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outrealupperband
        double outrealmiddleband
        double outreallowerband
    _state = <void*>state
    retCode = lib.TA_BBANDS_State( _state , real , &outrealupperband , &outrealmiddleband , &outreallowerband )
    need_mode_data = not _ta_check_success("TA_BBANDS_State", retCode)
    return TALibResult(retCode), outrealupperband , outrealmiddleband , outreallowerband 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BBANDS_BatchState( size_t state , np.ndarray real not None ):
    """ BBANDS_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outrealupperband
        np.ndarray outrealmiddleband
        np.ndarray outreallowerband
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outrealupperband = make_double_array(length, lookback)
    outrealmiddleband = make_double_array(length, lookback)
    outreallowerband = make_double_array(length, lookback)
    retCode = lib.TA_BBANDS_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outrealupperband.data)+lookback , <double *>(outrealmiddleband.data)+lookback , <double *>(outreallowerband.data)+lookback )
    _ta_check_success("TA_BBANDS_BatchState", retCode)
    return TALibResult(retCode), outrealupperband , outrealmiddleband , outreallowerband 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BBANDS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_BBANDS_StateFree( & _state )
    _ta_check_success("TA_BBANDS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BBANDS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "BBANDS"
    _state = <void*> state
    retCode = lib.TA_BBANDS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_BBANDS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BBANDS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_BBANDS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_BBANDS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BETA( np.ndarray real0 not None , np.ndarray real1 not None , int timeperiod=-2**31 ):
    """ BETA(real0, real1[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_BETA_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_BETA( 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_BETA", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BETA_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_BETA_StateInit(& _state, timeperiod)
    _ta_check_success("TA_BETA_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BETA_State( size_t state , double real0 , double real1 ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_BETA_State( _state , real0 , real1 , &outreal )
    need_mode_data = not _ta_check_success("TA_BETA_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BETA_BatchState( size_t state , np.ndarray real0 not None , np.ndarray real1 not None ):
    """ BETA_BatchState(real0, real1)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_BETA_BatchState( _state , 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_BETA_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BETA_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_BETA_StateFree( & _state )
    _ta_check_success("TA_BETA_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BETA_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "BETA"
    _state = <void*> state
    retCode = lib.TA_BETA_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_BETA_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BETA_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_BETA_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_BETA_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BOP( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ BOP(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_BOP_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_BOP( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_BOP", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BOP_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_BOP_StateInit(& _state)
    _ta_check_success("TA_BOP_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BOP_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_BOP_State( _state , open , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_BOP_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BOP_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ BOP_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_BOP_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_BOP_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BOP_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_BOP_StateFree( & _state )
    _ta_check_success("TA_BOP_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BOP_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "BOP"
    _state = <void*> state
    retCode = lib.TA_BOP_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_BOP_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def BOP_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_BOP_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_BOP_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CCI( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ CCI(high, low, close[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CCI_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_CCI( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_CCI", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CCI_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CCI_StateInit(& _state, timeperiod)
    _ta_check_success("TA_CCI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CCI_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_CCI_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_CCI_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CCI_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CCI_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_CCI_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_CCI_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CCI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CCI_StateFree( & _state )
    _ta_check_success("TA_CCI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CCI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CCI"
    _state = <void*> state
    retCode = lib.TA_CCI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CCI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CCI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CCI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CCI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL2CROWS( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL2CROWS(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDL2CROWS_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL2CROWS( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL2CROWS", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL2CROWS_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL2CROWS_StateInit(& _state)
    _ta_check_success("TA_CDL2CROWS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL2CROWS_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDL2CROWS_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDL2CROWS_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL2CROWS_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL2CROWS_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL2CROWS_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL2CROWS_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL2CROWS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDL2CROWS_StateFree( & _state )
    _ta_check_success("TA_CDL2CROWS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL2CROWS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDL2CROWS"
    _state = <void*> state
    retCode = lib.TA_CDL2CROWS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDL2CROWS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL2CROWS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL2CROWS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDL2CROWS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3BLACKCROWS( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3BLACKCROWS(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDL3BLACKCROWS_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3BLACKCROWS( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3BLACKCROWS", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3BLACKCROWS_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3BLACKCROWS_StateInit(& _state)
    _ta_check_success("TA_CDL3BLACKCROWS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3BLACKCROWS_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDL3BLACKCROWS_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDL3BLACKCROWS_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3BLACKCROWS_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3BLACKCROWS_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3BLACKCROWS_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3BLACKCROWS_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3BLACKCROWS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDL3BLACKCROWS_StateFree( & _state )
    _ta_check_success("TA_CDL3BLACKCROWS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3BLACKCROWS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDL3BLACKCROWS"
    _state = <void*> state
    retCode = lib.TA_CDL3BLACKCROWS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDL3BLACKCROWS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3BLACKCROWS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3BLACKCROWS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDL3BLACKCROWS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3INSIDE( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3INSIDE(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDL3INSIDE_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3INSIDE( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3INSIDE", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3INSIDE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3INSIDE_StateInit(& _state)
    _ta_check_success("TA_CDL3INSIDE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3INSIDE_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDL3INSIDE_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDL3INSIDE_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3INSIDE_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3INSIDE_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3INSIDE_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3INSIDE_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3INSIDE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDL3INSIDE_StateFree( & _state )
    _ta_check_success("TA_CDL3INSIDE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3INSIDE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDL3INSIDE"
    _state = <void*> state
    retCode = lib.TA_CDL3INSIDE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDL3INSIDE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3INSIDE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3INSIDE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDL3INSIDE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3LINESTRIKE( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3LINESTRIKE(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDL3LINESTRIKE_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3LINESTRIKE( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3LINESTRIKE", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3LINESTRIKE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3LINESTRIKE_StateInit(& _state)
    _ta_check_success("TA_CDL3LINESTRIKE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3LINESTRIKE_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDL3LINESTRIKE_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDL3LINESTRIKE_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3LINESTRIKE_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3LINESTRIKE_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3LINESTRIKE_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3LINESTRIKE_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3LINESTRIKE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDL3LINESTRIKE_StateFree( & _state )
    _ta_check_success("TA_CDL3LINESTRIKE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3LINESTRIKE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDL3LINESTRIKE"
    _state = <void*> state
    retCode = lib.TA_CDL3LINESTRIKE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDL3LINESTRIKE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3LINESTRIKE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3LINESTRIKE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDL3LINESTRIKE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3OUTSIDE( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3OUTSIDE(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDL3OUTSIDE_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3OUTSIDE( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3OUTSIDE", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3OUTSIDE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3OUTSIDE_StateInit(& _state)
    _ta_check_success("TA_CDL3OUTSIDE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3OUTSIDE_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDL3OUTSIDE_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDL3OUTSIDE_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3OUTSIDE_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3OUTSIDE_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3OUTSIDE_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3OUTSIDE_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3OUTSIDE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDL3OUTSIDE_StateFree( & _state )
    _ta_check_success("TA_CDL3OUTSIDE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3OUTSIDE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDL3OUTSIDE"
    _state = <void*> state
    retCode = lib.TA_CDL3OUTSIDE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDL3OUTSIDE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3OUTSIDE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3OUTSIDE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDL3OUTSIDE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3STARSINSOUTH( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3STARSINSOUTH(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDL3STARSINSOUTH_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3STARSINSOUTH( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3STARSINSOUTH", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3STARSINSOUTH_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3STARSINSOUTH_StateInit(& _state)
    _ta_check_success("TA_CDL3STARSINSOUTH_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3STARSINSOUTH_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDL3STARSINSOUTH_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDL3STARSINSOUTH_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3STARSINSOUTH_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3STARSINSOUTH_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3STARSINSOUTH_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3STARSINSOUTH_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3STARSINSOUTH_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDL3STARSINSOUTH_StateFree( & _state )
    _ta_check_success("TA_CDL3STARSINSOUTH_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3STARSINSOUTH_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDL3STARSINSOUTH"
    _state = <void*> state
    retCode = lib.TA_CDL3STARSINSOUTH_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDL3STARSINSOUTH_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3STARSINSOUTH_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3STARSINSOUTH_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDL3STARSINSOUTH_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3WHITESOLDIERS( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3WHITESOLDIERS(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDL3WHITESOLDIERS_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3WHITESOLDIERS( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3WHITESOLDIERS", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3WHITESOLDIERS_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3WHITESOLDIERS_StateInit(& _state)
    _ta_check_success("TA_CDL3WHITESOLDIERS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3WHITESOLDIERS_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDL3WHITESOLDIERS_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDL3WHITESOLDIERS_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3WHITESOLDIERS_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDL3WHITESOLDIERS_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDL3WHITESOLDIERS_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDL3WHITESOLDIERS_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3WHITESOLDIERS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDL3WHITESOLDIERS_StateFree( & _state )
    _ta_check_success("TA_CDL3WHITESOLDIERS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3WHITESOLDIERS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDL3WHITESOLDIERS"
    _state = <void*> state
    retCode = lib.TA_CDL3WHITESOLDIERS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDL3WHITESOLDIERS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDL3WHITESOLDIERS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDL3WHITESOLDIERS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDL3WHITESOLDIERS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLABANDONEDBABY( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , double penetration=-4e37 ):
    """ CDLABANDONEDBABY(open, high, low, close[, penetration=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLABANDONEDBABY_Lookback( penetration )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLABANDONEDBABY( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , penetration , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLABANDONEDBABY", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLABANDONEDBABY_StateInit( double penetration=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLABANDONEDBABY_StateInit(& _state, penetration)
    _ta_check_success("TA_CDLABANDONEDBABY_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLABANDONEDBABY_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLABANDONEDBABY_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLABANDONEDBABY_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLABANDONEDBABY_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLABANDONEDBABY_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLABANDONEDBABY_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLABANDONEDBABY_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLABANDONEDBABY_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLABANDONEDBABY_StateFree( & _state )
    _ta_check_success("TA_CDLABANDONEDBABY_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLABANDONEDBABY_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLABANDONEDBABY"
    _state = <void*> state
    retCode = lib.TA_CDLABANDONEDBABY_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLABANDONEDBABY_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLABANDONEDBABY_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLABANDONEDBABY_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLABANDONEDBABY_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLADVANCEBLOCK( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLADVANCEBLOCK(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLADVANCEBLOCK_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLADVANCEBLOCK( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLADVANCEBLOCK", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLADVANCEBLOCK_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLADVANCEBLOCK_StateInit(& _state)
    _ta_check_success("TA_CDLADVANCEBLOCK_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLADVANCEBLOCK_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLADVANCEBLOCK_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLADVANCEBLOCK_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLADVANCEBLOCK_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLADVANCEBLOCK_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLADVANCEBLOCK_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLADVANCEBLOCK_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLADVANCEBLOCK_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLADVANCEBLOCK_StateFree( & _state )
    _ta_check_success("TA_CDLADVANCEBLOCK_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLADVANCEBLOCK_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLADVANCEBLOCK"
    _state = <void*> state
    retCode = lib.TA_CDLADVANCEBLOCK_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLADVANCEBLOCK_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLADVANCEBLOCK_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLADVANCEBLOCK_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLADVANCEBLOCK_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBELTHOLD( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLBELTHOLD(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLBELTHOLD_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLBELTHOLD( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLBELTHOLD", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBELTHOLD_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLBELTHOLD_StateInit(& _state)
    _ta_check_success("TA_CDLBELTHOLD_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBELTHOLD_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLBELTHOLD_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLBELTHOLD_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBELTHOLD_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLBELTHOLD_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLBELTHOLD_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLBELTHOLD_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBELTHOLD_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLBELTHOLD_StateFree( & _state )
    _ta_check_success("TA_CDLBELTHOLD_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBELTHOLD_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLBELTHOLD"
    _state = <void*> state
    retCode = lib.TA_CDLBELTHOLD_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLBELTHOLD_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBELTHOLD_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLBELTHOLD_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLBELTHOLD_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBREAKAWAY( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLBREAKAWAY(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLBREAKAWAY_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLBREAKAWAY( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLBREAKAWAY", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBREAKAWAY_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLBREAKAWAY_StateInit(& _state)
    _ta_check_success("TA_CDLBREAKAWAY_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBREAKAWAY_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLBREAKAWAY_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLBREAKAWAY_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBREAKAWAY_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLBREAKAWAY_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLBREAKAWAY_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLBREAKAWAY_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBREAKAWAY_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLBREAKAWAY_StateFree( & _state )
    _ta_check_success("TA_CDLBREAKAWAY_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBREAKAWAY_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLBREAKAWAY"
    _state = <void*> state
    retCode = lib.TA_CDLBREAKAWAY_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLBREAKAWAY_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLBREAKAWAY_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLBREAKAWAY_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLBREAKAWAY_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCLOSINGMARUBOZU( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLCLOSINGMARUBOZU(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLCLOSINGMARUBOZU_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLCLOSINGMARUBOZU( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLCLOSINGMARUBOZU", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCLOSINGMARUBOZU_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLCLOSINGMARUBOZU_StateInit(& _state)
    _ta_check_success("TA_CDLCLOSINGMARUBOZU_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCLOSINGMARUBOZU_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLCLOSINGMARUBOZU_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLCLOSINGMARUBOZU_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCLOSINGMARUBOZU_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLCLOSINGMARUBOZU_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLCLOSINGMARUBOZU_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLCLOSINGMARUBOZU_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCLOSINGMARUBOZU_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLCLOSINGMARUBOZU_StateFree( & _state )
    _ta_check_success("TA_CDLCLOSINGMARUBOZU_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCLOSINGMARUBOZU_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLCLOSINGMARUBOZU"
    _state = <void*> state
    retCode = lib.TA_CDLCLOSINGMARUBOZU_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLCLOSINGMARUBOZU_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCLOSINGMARUBOZU_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLCLOSINGMARUBOZU_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLCLOSINGMARUBOZU_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCONCEALBABYSWALL( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLCONCEALBABYSWALL(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLCONCEALBABYSWALL_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLCONCEALBABYSWALL( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLCONCEALBABYSWALL", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCONCEALBABYSWALL_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLCONCEALBABYSWALL_StateInit(& _state)
    _ta_check_success("TA_CDLCONCEALBABYSWALL_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCONCEALBABYSWALL_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLCONCEALBABYSWALL_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLCONCEALBABYSWALL_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCONCEALBABYSWALL_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLCONCEALBABYSWALL_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLCONCEALBABYSWALL_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLCONCEALBABYSWALL_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCONCEALBABYSWALL_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLCONCEALBABYSWALL_StateFree( & _state )
    _ta_check_success("TA_CDLCONCEALBABYSWALL_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCONCEALBABYSWALL_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLCONCEALBABYSWALL"
    _state = <void*> state
    retCode = lib.TA_CDLCONCEALBABYSWALL_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLCONCEALBABYSWALL_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCONCEALBABYSWALL_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLCONCEALBABYSWALL_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLCONCEALBABYSWALL_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCOUNTERATTACK( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLCOUNTERATTACK(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLCOUNTERATTACK_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLCOUNTERATTACK( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLCOUNTERATTACK", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCOUNTERATTACK_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLCOUNTERATTACK_StateInit(& _state)
    _ta_check_success("TA_CDLCOUNTERATTACK_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCOUNTERATTACK_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLCOUNTERATTACK_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLCOUNTERATTACK_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCOUNTERATTACK_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLCOUNTERATTACK_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLCOUNTERATTACK_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLCOUNTERATTACK_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCOUNTERATTACK_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLCOUNTERATTACK_StateFree( & _state )
    _ta_check_success("TA_CDLCOUNTERATTACK_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCOUNTERATTACK_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLCOUNTERATTACK"
    _state = <void*> state
    retCode = lib.TA_CDLCOUNTERATTACK_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLCOUNTERATTACK_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLCOUNTERATTACK_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLCOUNTERATTACK_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLCOUNTERATTACK_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDARKCLOUDCOVER( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , double penetration=-4e37 ):
    """ CDLDARKCLOUDCOVER(open, high, low, close[, penetration=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLDARKCLOUDCOVER_Lookback( penetration )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLDARKCLOUDCOVER( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , penetration , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLDARKCLOUDCOVER", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDARKCLOUDCOVER_StateInit( double penetration=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLDARKCLOUDCOVER_StateInit(& _state, penetration)
    _ta_check_success("TA_CDLDARKCLOUDCOVER_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDARKCLOUDCOVER_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLDARKCLOUDCOVER_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLDARKCLOUDCOVER_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDARKCLOUDCOVER_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLDARKCLOUDCOVER_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLDARKCLOUDCOVER_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLDARKCLOUDCOVER_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDARKCLOUDCOVER_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLDARKCLOUDCOVER_StateFree( & _state )
    _ta_check_success("TA_CDLDARKCLOUDCOVER_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDARKCLOUDCOVER_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLDARKCLOUDCOVER"
    _state = <void*> state
    retCode = lib.TA_CDLDARKCLOUDCOVER_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLDARKCLOUDCOVER_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDARKCLOUDCOVER_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLDARKCLOUDCOVER_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLDARKCLOUDCOVER_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJI( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLDOJI(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLDOJI_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLDOJI( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLDOJI", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJI_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLDOJI_StateInit(& _state)
    _ta_check_success("TA_CDLDOJI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJI_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLDOJI_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLDOJI_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJI_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLDOJI_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLDOJI_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLDOJI_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLDOJI_StateFree( & _state )
    _ta_check_success("TA_CDLDOJI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLDOJI"
    _state = <void*> state
    retCode = lib.TA_CDLDOJI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLDOJI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLDOJI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLDOJI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJISTAR( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLDOJISTAR(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLDOJISTAR_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLDOJISTAR( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLDOJISTAR", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJISTAR_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLDOJISTAR_StateInit(& _state)
    _ta_check_success("TA_CDLDOJISTAR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJISTAR_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLDOJISTAR_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLDOJISTAR_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJISTAR_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLDOJISTAR_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLDOJISTAR_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLDOJISTAR_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJISTAR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLDOJISTAR_StateFree( & _state )
    _ta_check_success("TA_CDLDOJISTAR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJISTAR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLDOJISTAR"
    _state = <void*> state
    retCode = lib.TA_CDLDOJISTAR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLDOJISTAR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDOJISTAR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLDOJISTAR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLDOJISTAR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDRAGONFLYDOJI( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLDRAGONFLYDOJI(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLDRAGONFLYDOJI_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLDRAGONFLYDOJI( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLDRAGONFLYDOJI", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDRAGONFLYDOJI_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLDRAGONFLYDOJI_StateInit(& _state)
    _ta_check_success("TA_CDLDRAGONFLYDOJI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDRAGONFLYDOJI_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLDRAGONFLYDOJI_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLDRAGONFLYDOJI_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDRAGONFLYDOJI_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLDRAGONFLYDOJI_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLDRAGONFLYDOJI_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLDRAGONFLYDOJI_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDRAGONFLYDOJI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLDRAGONFLYDOJI_StateFree( & _state )
    _ta_check_success("TA_CDLDRAGONFLYDOJI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDRAGONFLYDOJI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLDRAGONFLYDOJI"
    _state = <void*> state
    retCode = lib.TA_CDLDRAGONFLYDOJI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLDRAGONFLYDOJI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLDRAGONFLYDOJI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLDRAGONFLYDOJI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLDRAGONFLYDOJI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLENGULFING( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLENGULFING(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLENGULFING_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLENGULFING( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLENGULFING", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLENGULFING_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLENGULFING_StateInit(& _state)
    _ta_check_success("TA_CDLENGULFING_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLENGULFING_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLENGULFING_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLENGULFING_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLENGULFING_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLENGULFING_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLENGULFING_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLENGULFING_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLENGULFING_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLENGULFING_StateFree( & _state )
    _ta_check_success("TA_CDLENGULFING_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLENGULFING_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLENGULFING"
    _state = <void*> state
    retCode = lib.TA_CDLENGULFING_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLENGULFING_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLENGULFING_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLENGULFING_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLENGULFING_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGDOJISTAR( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , double penetration=-4e37 ):
    """ CDLEVENINGDOJISTAR(open, high, low, close[, penetration=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLEVENINGDOJISTAR_Lookback( penetration )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLEVENINGDOJISTAR( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , penetration , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLEVENINGDOJISTAR", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGDOJISTAR_StateInit( double penetration=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLEVENINGDOJISTAR_StateInit(& _state, penetration)
    _ta_check_success("TA_CDLEVENINGDOJISTAR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGDOJISTAR_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLEVENINGDOJISTAR_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLEVENINGDOJISTAR_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGDOJISTAR_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLEVENINGDOJISTAR_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLEVENINGDOJISTAR_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLEVENINGDOJISTAR_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGDOJISTAR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLEVENINGDOJISTAR_StateFree( & _state )
    _ta_check_success("TA_CDLEVENINGDOJISTAR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGDOJISTAR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLEVENINGDOJISTAR"
    _state = <void*> state
    retCode = lib.TA_CDLEVENINGDOJISTAR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLEVENINGDOJISTAR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGDOJISTAR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLEVENINGDOJISTAR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLEVENINGDOJISTAR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGSTAR( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , double penetration=-4e37 ):
    """ CDLEVENINGSTAR(open, high, low, close[, penetration=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLEVENINGSTAR_Lookback( penetration )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLEVENINGSTAR( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , penetration , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLEVENINGSTAR", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGSTAR_StateInit( double penetration=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLEVENINGSTAR_StateInit(& _state, penetration)
    _ta_check_success("TA_CDLEVENINGSTAR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGSTAR_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLEVENINGSTAR_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLEVENINGSTAR_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGSTAR_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLEVENINGSTAR_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLEVENINGSTAR_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLEVENINGSTAR_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGSTAR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLEVENINGSTAR_StateFree( & _state )
    _ta_check_success("TA_CDLEVENINGSTAR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGSTAR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLEVENINGSTAR"
    _state = <void*> state
    retCode = lib.TA_CDLEVENINGSTAR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLEVENINGSTAR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLEVENINGSTAR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLEVENINGSTAR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLEVENINGSTAR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGAPSIDESIDEWHITE( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLGAPSIDESIDEWHITE(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLGAPSIDESIDEWHITE_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLGAPSIDESIDEWHITE( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLGAPSIDESIDEWHITE", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGAPSIDESIDEWHITE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLGAPSIDESIDEWHITE_StateInit(& _state)
    _ta_check_success("TA_CDLGAPSIDESIDEWHITE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGAPSIDESIDEWHITE_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLGAPSIDESIDEWHITE_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLGAPSIDESIDEWHITE_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGAPSIDESIDEWHITE_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLGAPSIDESIDEWHITE_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLGAPSIDESIDEWHITE_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLGAPSIDESIDEWHITE_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGAPSIDESIDEWHITE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLGAPSIDESIDEWHITE_StateFree( & _state )
    _ta_check_success("TA_CDLGAPSIDESIDEWHITE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGAPSIDESIDEWHITE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLGAPSIDESIDEWHITE"
    _state = <void*> state
    retCode = lib.TA_CDLGAPSIDESIDEWHITE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLGAPSIDESIDEWHITE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGAPSIDESIDEWHITE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLGAPSIDESIDEWHITE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLGAPSIDESIDEWHITE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGRAVESTONEDOJI( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLGRAVESTONEDOJI(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLGRAVESTONEDOJI_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLGRAVESTONEDOJI( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLGRAVESTONEDOJI", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGRAVESTONEDOJI_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLGRAVESTONEDOJI_StateInit(& _state)
    _ta_check_success("TA_CDLGRAVESTONEDOJI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGRAVESTONEDOJI_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLGRAVESTONEDOJI_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLGRAVESTONEDOJI_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGRAVESTONEDOJI_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLGRAVESTONEDOJI_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLGRAVESTONEDOJI_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLGRAVESTONEDOJI_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGRAVESTONEDOJI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLGRAVESTONEDOJI_StateFree( & _state )
    _ta_check_success("TA_CDLGRAVESTONEDOJI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGRAVESTONEDOJI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLGRAVESTONEDOJI"
    _state = <void*> state
    retCode = lib.TA_CDLGRAVESTONEDOJI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLGRAVESTONEDOJI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLGRAVESTONEDOJI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLGRAVESTONEDOJI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLGRAVESTONEDOJI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHAMMER( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHAMMER(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLHAMMER_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHAMMER( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHAMMER", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHAMMER_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHAMMER_StateInit(& _state)
    _ta_check_success("TA_CDLHAMMER_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHAMMER_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLHAMMER_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLHAMMER_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHAMMER_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHAMMER_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHAMMER_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHAMMER_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHAMMER_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLHAMMER_StateFree( & _state )
    _ta_check_success("TA_CDLHAMMER_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHAMMER_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLHAMMER"
    _state = <void*> state
    retCode = lib.TA_CDLHAMMER_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLHAMMER_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHAMMER_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHAMMER_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLHAMMER_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHANGINGMAN( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHANGINGMAN(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLHANGINGMAN_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHANGINGMAN( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHANGINGMAN", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHANGINGMAN_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHANGINGMAN_StateInit(& _state)
    _ta_check_success("TA_CDLHANGINGMAN_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHANGINGMAN_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLHANGINGMAN_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLHANGINGMAN_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHANGINGMAN_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHANGINGMAN_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHANGINGMAN_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHANGINGMAN_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHANGINGMAN_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLHANGINGMAN_StateFree( & _state )
    _ta_check_success("TA_CDLHANGINGMAN_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHANGINGMAN_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLHANGINGMAN"
    _state = <void*> state
    retCode = lib.TA_CDLHANGINGMAN_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLHANGINGMAN_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHANGINGMAN_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHANGINGMAN_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLHANGINGMAN_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMI( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHARAMI(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLHARAMI_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHARAMI( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHARAMI", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMI_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHARAMI_StateInit(& _state)
    _ta_check_success("TA_CDLHARAMI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMI_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLHARAMI_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLHARAMI_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMI_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHARAMI_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHARAMI_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHARAMI_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLHARAMI_StateFree( & _state )
    _ta_check_success("TA_CDLHARAMI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLHARAMI"
    _state = <void*> state
    retCode = lib.TA_CDLHARAMI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLHARAMI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHARAMI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLHARAMI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMICROSS( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHARAMICROSS(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLHARAMICROSS_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHARAMICROSS( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHARAMICROSS", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMICROSS_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHARAMICROSS_StateInit(& _state)
    _ta_check_success("TA_CDLHARAMICROSS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMICROSS_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLHARAMICROSS_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLHARAMICROSS_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMICROSS_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHARAMICROSS_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHARAMICROSS_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHARAMICROSS_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMICROSS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLHARAMICROSS_StateFree( & _state )
    _ta_check_success("TA_CDLHARAMICROSS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMICROSS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLHARAMICROSS"
    _state = <void*> state
    retCode = lib.TA_CDLHARAMICROSS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLHARAMICROSS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHARAMICROSS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHARAMICROSS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLHARAMICROSS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIGHWAVE( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHIGHWAVE(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLHIGHWAVE_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHIGHWAVE( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHIGHWAVE", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIGHWAVE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHIGHWAVE_StateInit(& _state)
    _ta_check_success("TA_CDLHIGHWAVE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIGHWAVE_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLHIGHWAVE_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLHIGHWAVE_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIGHWAVE_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHIGHWAVE_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHIGHWAVE_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHIGHWAVE_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIGHWAVE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLHIGHWAVE_StateFree( & _state )
    _ta_check_success("TA_CDLHIGHWAVE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIGHWAVE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLHIGHWAVE"
    _state = <void*> state
    retCode = lib.TA_CDLHIGHWAVE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLHIGHWAVE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIGHWAVE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHIGHWAVE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLHIGHWAVE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKE( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHIKKAKE(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLHIKKAKE_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHIKKAKE( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHIKKAKE", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHIKKAKE_StateInit(& _state)
    _ta_check_success("TA_CDLHIKKAKE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKE_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLHIKKAKE_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLHIKKAKE_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKE_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHIKKAKE_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHIKKAKE_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHIKKAKE_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLHIKKAKE_StateFree( & _state )
    _ta_check_success("TA_CDLHIKKAKE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLHIKKAKE"
    _state = <void*> state
    retCode = lib.TA_CDLHIKKAKE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLHIKKAKE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHIKKAKE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLHIKKAKE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKEMOD( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHIKKAKEMOD(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLHIKKAKEMOD_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHIKKAKEMOD( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHIKKAKEMOD", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKEMOD_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHIKKAKEMOD_StateInit(& _state)
    _ta_check_success("TA_CDLHIKKAKEMOD_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKEMOD_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLHIKKAKEMOD_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLHIKKAKEMOD_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKEMOD_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHIKKAKEMOD_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHIKKAKEMOD_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHIKKAKEMOD_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKEMOD_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLHIKKAKEMOD_StateFree( & _state )
    _ta_check_success("TA_CDLHIKKAKEMOD_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKEMOD_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLHIKKAKEMOD"
    _state = <void*> state
    retCode = lib.TA_CDLHIKKAKEMOD_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLHIKKAKEMOD_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHIKKAKEMOD_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHIKKAKEMOD_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLHIKKAKEMOD_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHOMINGPIGEON( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHOMINGPIGEON(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLHOMINGPIGEON_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHOMINGPIGEON( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHOMINGPIGEON", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHOMINGPIGEON_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHOMINGPIGEON_StateInit(& _state)
    _ta_check_success("TA_CDLHOMINGPIGEON_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHOMINGPIGEON_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLHOMINGPIGEON_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLHOMINGPIGEON_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHOMINGPIGEON_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLHOMINGPIGEON_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLHOMINGPIGEON_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLHOMINGPIGEON_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHOMINGPIGEON_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLHOMINGPIGEON_StateFree( & _state )
    _ta_check_success("TA_CDLHOMINGPIGEON_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHOMINGPIGEON_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLHOMINGPIGEON"
    _state = <void*> state
    retCode = lib.TA_CDLHOMINGPIGEON_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLHOMINGPIGEON_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLHOMINGPIGEON_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLHOMINGPIGEON_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLHOMINGPIGEON_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLIDENTICAL3CROWS( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLIDENTICAL3CROWS(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLIDENTICAL3CROWS_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLIDENTICAL3CROWS( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLIDENTICAL3CROWS", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLIDENTICAL3CROWS_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLIDENTICAL3CROWS_StateInit(& _state)
    _ta_check_success("TA_CDLIDENTICAL3CROWS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLIDENTICAL3CROWS_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLIDENTICAL3CROWS_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLIDENTICAL3CROWS_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLIDENTICAL3CROWS_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLIDENTICAL3CROWS_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLIDENTICAL3CROWS_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLIDENTICAL3CROWS_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLIDENTICAL3CROWS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLIDENTICAL3CROWS_StateFree( & _state )
    _ta_check_success("TA_CDLIDENTICAL3CROWS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLIDENTICAL3CROWS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLIDENTICAL3CROWS"
    _state = <void*> state
    retCode = lib.TA_CDLIDENTICAL3CROWS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLIDENTICAL3CROWS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLIDENTICAL3CROWS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLIDENTICAL3CROWS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLIDENTICAL3CROWS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINNECK( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLINNECK(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLINNECK_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLINNECK( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLINNECK", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINNECK_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLINNECK_StateInit(& _state)
    _ta_check_success("TA_CDLINNECK_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINNECK_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLINNECK_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLINNECK_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINNECK_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLINNECK_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLINNECK_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLINNECK_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINNECK_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLINNECK_StateFree( & _state )
    _ta_check_success("TA_CDLINNECK_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINNECK_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLINNECK"
    _state = <void*> state
    retCode = lib.TA_CDLINNECK_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLINNECK_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINNECK_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLINNECK_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLINNECK_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINVERTEDHAMMER( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLINVERTEDHAMMER(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLINVERTEDHAMMER_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLINVERTEDHAMMER( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLINVERTEDHAMMER", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINVERTEDHAMMER_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLINVERTEDHAMMER_StateInit(& _state)
    _ta_check_success("TA_CDLINVERTEDHAMMER_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINVERTEDHAMMER_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLINVERTEDHAMMER_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLINVERTEDHAMMER_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINVERTEDHAMMER_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLINVERTEDHAMMER_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLINVERTEDHAMMER_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLINVERTEDHAMMER_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINVERTEDHAMMER_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLINVERTEDHAMMER_StateFree( & _state )
    _ta_check_success("TA_CDLINVERTEDHAMMER_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINVERTEDHAMMER_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLINVERTEDHAMMER"
    _state = <void*> state
    retCode = lib.TA_CDLINVERTEDHAMMER_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLINVERTEDHAMMER_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLINVERTEDHAMMER_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLINVERTEDHAMMER_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLINVERTEDHAMMER_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKING( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLKICKING(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLKICKING_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLKICKING( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLKICKING", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKING_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLKICKING_StateInit(& _state)
    _ta_check_success("TA_CDLKICKING_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKING_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLKICKING_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLKICKING_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKING_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLKICKING_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLKICKING_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLKICKING_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKING_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLKICKING_StateFree( & _state )
    _ta_check_success("TA_CDLKICKING_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKING_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLKICKING"
    _state = <void*> state
    retCode = lib.TA_CDLKICKING_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLKICKING_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKING_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLKICKING_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLKICKING_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKINGBYLENGTH( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLKICKINGBYLENGTH(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLKICKINGBYLENGTH_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLKICKINGBYLENGTH( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLKICKINGBYLENGTH", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKINGBYLENGTH_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLKICKINGBYLENGTH_StateInit(& _state)
    _ta_check_success("TA_CDLKICKINGBYLENGTH_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKINGBYLENGTH_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLKICKINGBYLENGTH_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLKICKINGBYLENGTH_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKINGBYLENGTH_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLKICKINGBYLENGTH_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLKICKINGBYLENGTH_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLKICKINGBYLENGTH_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKINGBYLENGTH_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLKICKINGBYLENGTH_StateFree( & _state )
    _ta_check_success("TA_CDLKICKINGBYLENGTH_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKINGBYLENGTH_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLKICKINGBYLENGTH"
    _state = <void*> state
    retCode = lib.TA_CDLKICKINGBYLENGTH_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLKICKINGBYLENGTH_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLKICKINGBYLENGTH_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLKICKINGBYLENGTH_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLKICKINGBYLENGTH_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLADDERBOTTOM( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLLADDERBOTTOM(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLLADDERBOTTOM_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLLADDERBOTTOM( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLLADDERBOTTOM", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLADDERBOTTOM_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLLADDERBOTTOM_StateInit(& _state)
    _ta_check_success("TA_CDLLADDERBOTTOM_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLADDERBOTTOM_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLLADDERBOTTOM_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLLADDERBOTTOM_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLADDERBOTTOM_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLLADDERBOTTOM_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLLADDERBOTTOM_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLLADDERBOTTOM_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLADDERBOTTOM_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLLADDERBOTTOM_StateFree( & _state )
    _ta_check_success("TA_CDLLADDERBOTTOM_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLADDERBOTTOM_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLLADDERBOTTOM"
    _state = <void*> state
    retCode = lib.TA_CDLLADDERBOTTOM_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLLADDERBOTTOM_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLADDERBOTTOM_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLLADDERBOTTOM_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLLADDERBOTTOM_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLEGGEDDOJI( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLLONGLEGGEDDOJI(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLLONGLEGGEDDOJI_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLLONGLEGGEDDOJI( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLLONGLEGGEDDOJI", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLEGGEDDOJI_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLLONGLEGGEDDOJI_StateInit(& _state)
    _ta_check_success("TA_CDLLONGLEGGEDDOJI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLEGGEDDOJI_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLLONGLEGGEDDOJI_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLLONGLEGGEDDOJI_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLEGGEDDOJI_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLLONGLEGGEDDOJI_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLLONGLEGGEDDOJI_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLLONGLEGGEDDOJI_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLEGGEDDOJI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLLONGLEGGEDDOJI_StateFree( & _state )
    _ta_check_success("TA_CDLLONGLEGGEDDOJI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLEGGEDDOJI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLLONGLEGGEDDOJI"
    _state = <void*> state
    retCode = lib.TA_CDLLONGLEGGEDDOJI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLLONGLEGGEDDOJI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLEGGEDDOJI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLLONGLEGGEDDOJI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLLONGLEGGEDDOJI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLINE( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLLONGLINE(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLLONGLINE_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLLONGLINE( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLLONGLINE", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLINE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLLONGLINE_StateInit(& _state)
    _ta_check_success("TA_CDLLONGLINE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLINE_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLLONGLINE_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLLONGLINE_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLINE_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLLONGLINE_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLLONGLINE_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLLONGLINE_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLINE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLLONGLINE_StateFree( & _state )
    _ta_check_success("TA_CDLLONGLINE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLINE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLLONGLINE"
    _state = <void*> state
    retCode = lib.TA_CDLLONGLINE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLLONGLINE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLLONGLINE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLLONGLINE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLLONGLINE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMARUBOZU( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLMARUBOZU(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLMARUBOZU_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLMARUBOZU( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLMARUBOZU", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMARUBOZU_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLMARUBOZU_StateInit(& _state)
    _ta_check_success("TA_CDLMARUBOZU_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMARUBOZU_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLMARUBOZU_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLMARUBOZU_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMARUBOZU_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLMARUBOZU_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLMARUBOZU_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLMARUBOZU_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMARUBOZU_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLMARUBOZU_StateFree( & _state )
    _ta_check_success("TA_CDLMARUBOZU_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMARUBOZU_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLMARUBOZU"
    _state = <void*> state
    retCode = lib.TA_CDLMARUBOZU_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLMARUBOZU_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMARUBOZU_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLMARUBOZU_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLMARUBOZU_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATCHINGLOW( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLMATCHINGLOW(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLMATCHINGLOW_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLMATCHINGLOW( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLMATCHINGLOW", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATCHINGLOW_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLMATCHINGLOW_StateInit(& _state)
    _ta_check_success("TA_CDLMATCHINGLOW_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATCHINGLOW_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLMATCHINGLOW_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLMATCHINGLOW_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATCHINGLOW_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLMATCHINGLOW_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLMATCHINGLOW_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLMATCHINGLOW_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATCHINGLOW_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLMATCHINGLOW_StateFree( & _state )
    _ta_check_success("TA_CDLMATCHINGLOW_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATCHINGLOW_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLMATCHINGLOW"
    _state = <void*> state
    retCode = lib.TA_CDLMATCHINGLOW_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLMATCHINGLOW_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATCHINGLOW_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLMATCHINGLOW_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLMATCHINGLOW_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATHOLD( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , double penetration=-4e37 ):
    """ CDLMATHOLD(open, high, low, close[, penetration=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLMATHOLD_Lookback( penetration )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLMATHOLD( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , penetration , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLMATHOLD", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATHOLD_StateInit( double penetration=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLMATHOLD_StateInit(& _state, penetration)
    _ta_check_success("TA_CDLMATHOLD_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATHOLD_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLMATHOLD_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLMATHOLD_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATHOLD_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLMATHOLD_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLMATHOLD_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLMATHOLD_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATHOLD_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLMATHOLD_StateFree( & _state )
    _ta_check_success("TA_CDLMATHOLD_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATHOLD_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLMATHOLD"
    _state = <void*> state
    retCode = lib.TA_CDLMATHOLD_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLMATHOLD_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMATHOLD_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLMATHOLD_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLMATHOLD_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGDOJISTAR( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , double penetration=-4e37 ):
    """ CDLMORNINGDOJISTAR(open, high, low, close[, penetration=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLMORNINGDOJISTAR_Lookback( penetration )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLMORNINGDOJISTAR( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , penetration , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLMORNINGDOJISTAR", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGDOJISTAR_StateInit( double penetration=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLMORNINGDOJISTAR_StateInit(& _state, penetration)
    _ta_check_success("TA_CDLMORNINGDOJISTAR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGDOJISTAR_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLMORNINGDOJISTAR_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLMORNINGDOJISTAR_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGDOJISTAR_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLMORNINGDOJISTAR_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLMORNINGDOJISTAR_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLMORNINGDOJISTAR_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGDOJISTAR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLMORNINGDOJISTAR_StateFree( & _state )
    _ta_check_success("TA_CDLMORNINGDOJISTAR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGDOJISTAR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLMORNINGDOJISTAR"
    _state = <void*> state
    retCode = lib.TA_CDLMORNINGDOJISTAR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLMORNINGDOJISTAR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGDOJISTAR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLMORNINGDOJISTAR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLMORNINGDOJISTAR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGSTAR( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , double penetration=-4e37 ):
    """ CDLMORNINGSTAR(open, high, low, close[, penetration=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLMORNINGSTAR_Lookback( penetration )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLMORNINGSTAR( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , penetration , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLMORNINGSTAR", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGSTAR_StateInit( double penetration=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLMORNINGSTAR_StateInit(& _state, penetration)
    _ta_check_success("TA_CDLMORNINGSTAR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGSTAR_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLMORNINGSTAR_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLMORNINGSTAR_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGSTAR_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLMORNINGSTAR_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLMORNINGSTAR_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLMORNINGSTAR_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGSTAR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLMORNINGSTAR_StateFree( & _state )
    _ta_check_success("TA_CDLMORNINGSTAR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGSTAR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLMORNINGSTAR"
    _state = <void*> state
    retCode = lib.TA_CDLMORNINGSTAR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLMORNINGSTAR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLMORNINGSTAR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLMORNINGSTAR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLMORNINGSTAR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLONNECK( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLONNECK(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLONNECK_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLONNECK( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLONNECK", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLONNECK_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLONNECK_StateInit(& _state)
    _ta_check_success("TA_CDLONNECK_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLONNECK_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLONNECK_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLONNECK_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLONNECK_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLONNECK_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLONNECK_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLONNECK_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLONNECK_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLONNECK_StateFree( & _state )
    _ta_check_success("TA_CDLONNECK_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLONNECK_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLONNECK"
    _state = <void*> state
    retCode = lib.TA_CDLONNECK_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLONNECK_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLONNECK_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLONNECK_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLONNECK_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLPIERCING( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLPIERCING(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLPIERCING_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLPIERCING( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLPIERCING", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLPIERCING_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLPIERCING_StateInit(& _state)
    _ta_check_success("TA_CDLPIERCING_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLPIERCING_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLPIERCING_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLPIERCING_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLPIERCING_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLPIERCING_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLPIERCING_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLPIERCING_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLPIERCING_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLPIERCING_StateFree( & _state )
    _ta_check_success("TA_CDLPIERCING_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLPIERCING_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLPIERCING"
    _state = <void*> state
    retCode = lib.TA_CDLPIERCING_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLPIERCING_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLPIERCING_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLPIERCING_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLPIERCING_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRICKSHAWMAN( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLRICKSHAWMAN(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLRICKSHAWMAN_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLRICKSHAWMAN( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLRICKSHAWMAN", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRICKSHAWMAN_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLRICKSHAWMAN_StateInit(& _state)
    _ta_check_success("TA_CDLRICKSHAWMAN_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRICKSHAWMAN_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLRICKSHAWMAN_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLRICKSHAWMAN_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRICKSHAWMAN_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLRICKSHAWMAN_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLRICKSHAWMAN_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLRICKSHAWMAN_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRICKSHAWMAN_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLRICKSHAWMAN_StateFree( & _state )
    _ta_check_success("TA_CDLRICKSHAWMAN_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRICKSHAWMAN_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLRICKSHAWMAN"
    _state = <void*> state
    retCode = lib.TA_CDLRICKSHAWMAN_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLRICKSHAWMAN_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRICKSHAWMAN_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLRICKSHAWMAN_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLRICKSHAWMAN_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRISEFALL3METHODS( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLRISEFALL3METHODS(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLRISEFALL3METHODS_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLRISEFALL3METHODS( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLRISEFALL3METHODS", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRISEFALL3METHODS_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLRISEFALL3METHODS_StateInit(& _state)
    _ta_check_success("TA_CDLRISEFALL3METHODS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRISEFALL3METHODS_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLRISEFALL3METHODS_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLRISEFALL3METHODS_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRISEFALL3METHODS_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLRISEFALL3METHODS_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLRISEFALL3METHODS_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLRISEFALL3METHODS_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRISEFALL3METHODS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLRISEFALL3METHODS_StateFree( & _state )
    _ta_check_success("TA_CDLRISEFALL3METHODS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRISEFALL3METHODS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLRISEFALL3METHODS"
    _state = <void*> state
    retCode = lib.TA_CDLRISEFALL3METHODS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLRISEFALL3METHODS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLRISEFALL3METHODS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLRISEFALL3METHODS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLRISEFALL3METHODS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSEPARATINGLINES( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSEPARATINGLINES(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLSEPARATINGLINES_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSEPARATINGLINES( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSEPARATINGLINES", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSEPARATINGLINES_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSEPARATINGLINES_StateInit(& _state)
    _ta_check_success("TA_CDLSEPARATINGLINES_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSEPARATINGLINES_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLSEPARATINGLINES_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLSEPARATINGLINES_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSEPARATINGLINES_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSEPARATINGLINES_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSEPARATINGLINES_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSEPARATINGLINES_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSEPARATINGLINES_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLSEPARATINGLINES_StateFree( & _state )
    _ta_check_success("TA_CDLSEPARATINGLINES_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSEPARATINGLINES_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLSEPARATINGLINES"
    _state = <void*> state
    retCode = lib.TA_CDLSEPARATINGLINES_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLSEPARATINGLINES_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSEPARATINGLINES_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSEPARATINGLINES_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLSEPARATINGLINES_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHOOTINGSTAR( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSHOOTINGSTAR(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLSHOOTINGSTAR_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSHOOTINGSTAR( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSHOOTINGSTAR", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHOOTINGSTAR_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSHOOTINGSTAR_StateInit(& _state)
    _ta_check_success("TA_CDLSHOOTINGSTAR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHOOTINGSTAR_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLSHOOTINGSTAR_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLSHOOTINGSTAR_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHOOTINGSTAR_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSHOOTINGSTAR_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSHOOTINGSTAR_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSHOOTINGSTAR_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHOOTINGSTAR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLSHOOTINGSTAR_StateFree( & _state )
    _ta_check_success("TA_CDLSHOOTINGSTAR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHOOTINGSTAR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLSHOOTINGSTAR"
    _state = <void*> state
    retCode = lib.TA_CDLSHOOTINGSTAR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLSHOOTINGSTAR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHOOTINGSTAR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSHOOTINGSTAR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLSHOOTINGSTAR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHORTLINE( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSHORTLINE(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLSHORTLINE_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSHORTLINE( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSHORTLINE", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHORTLINE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSHORTLINE_StateInit(& _state)
    _ta_check_success("TA_CDLSHORTLINE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHORTLINE_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLSHORTLINE_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLSHORTLINE_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHORTLINE_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSHORTLINE_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSHORTLINE_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSHORTLINE_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHORTLINE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLSHORTLINE_StateFree( & _state )
    _ta_check_success("TA_CDLSHORTLINE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHORTLINE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLSHORTLINE"
    _state = <void*> state
    retCode = lib.TA_CDLSHORTLINE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLSHORTLINE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSHORTLINE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSHORTLINE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLSHORTLINE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSPINNINGTOP( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSPINNINGTOP(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLSPINNINGTOP_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSPINNINGTOP( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSPINNINGTOP", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSPINNINGTOP_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSPINNINGTOP_StateInit(& _state)
    _ta_check_success("TA_CDLSPINNINGTOP_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSPINNINGTOP_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLSPINNINGTOP_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLSPINNINGTOP_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSPINNINGTOP_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSPINNINGTOP_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSPINNINGTOP_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSPINNINGTOP_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSPINNINGTOP_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLSPINNINGTOP_StateFree( & _state )
    _ta_check_success("TA_CDLSPINNINGTOP_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSPINNINGTOP_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLSPINNINGTOP"
    _state = <void*> state
    retCode = lib.TA_CDLSPINNINGTOP_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLSPINNINGTOP_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSPINNINGTOP_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSPINNINGTOP_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLSPINNINGTOP_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTALLEDPATTERN( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSTALLEDPATTERN(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLSTALLEDPATTERN_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSTALLEDPATTERN( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSTALLEDPATTERN", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTALLEDPATTERN_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSTALLEDPATTERN_StateInit(& _state)
    _ta_check_success("TA_CDLSTALLEDPATTERN_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTALLEDPATTERN_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLSTALLEDPATTERN_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLSTALLEDPATTERN_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTALLEDPATTERN_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSTALLEDPATTERN_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSTALLEDPATTERN_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSTALLEDPATTERN_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTALLEDPATTERN_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLSTALLEDPATTERN_StateFree( & _state )
    _ta_check_success("TA_CDLSTALLEDPATTERN_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTALLEDPATTERN_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLSTALLEDPATTERN"
    _state = <void*> state
    retCode = lib.TA_CDLSTALLEDPATTERN_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLSTALLEDPATTERN_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTALLEDPATTERN_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSTALLEDPATTERN_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLSTALLEDPATTERN_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTICKSANDWICH( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSTICKSANDWICH(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLSTICKSANDWICH_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSTICKSANDWICH( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSTICKSANDWICH", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTICKSANDWICH_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSTICKSANDWICH_StateInit(& _state)
    _ta_check_success("TA_CDLSTICKSANDWICH_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTICKSANDWICH_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLSTICKSANDWICH_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLSTICKSANDWICH_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTICKSANDWICH_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLSTICKSANDWICH_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLSTICKSANDWICH_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLSTICKSANDWICH_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTICKSANDWICH_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLSTICKSANDWICH_StateFree( & _state )
    _ta_check_success("TA_CDLSTICKSANDWICH_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTICKSANDWICH_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLSTICKSANDWICH"
    _state = <void*> state
    retCode = lib.TA_CDLSTICKSANDWICH_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLSTICKSANDWICH_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLSTICKSANDWICH_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLSTICKSANDWICH_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLSTICKSANDWICH_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTAKURI( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLTAKURI(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLTAKURI_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLTAKURI( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLTAKURI", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTAKURI_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLTAKURI_StateInit(& _state)
    _ta_check_success("TA_CDLTAKURI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTAKURI_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLTAKURI_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLTAKURI_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTAKURI_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLTAKURI_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLTAKURI_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLTAKURI_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTAKURI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLTAKURI_StateFree( & _state )
    _ta_check_success("TA_CDLTAKURI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTAKURI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLTAKURI"
    _state = <void*> state
    retCode = lib.TA_CDLTAKURI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLTAKURI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTAKURI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLTAKURI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLTAKURI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTASUKIGAP( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLTASUKIGAP(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLTASUKIGAP_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLTASUKIGAP( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLTASUKIGAP", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTASUKIGAP_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLTASUKIGAP_StateInit(& _state)
    _ta_check_success("TA_CDLTASUKIGAP_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTASUKIGAP_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLTASUKIGAP_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLTASUKIGAP_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTASUKIGAP_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLTASUKIGAP_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLTASUKIGAP_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLTASUKIGAP_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTASUKIGAP_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLTASUKIGAP_StateFree( & _state )
    _ta_check_success("TA_CDLTASUKIGAP_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTASUKIGAP_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLTASUKIGAP"
    _state = <void*> state
    retCode = lib.TA_CDLTASUKIGAP_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLTASUKIGAP_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTASUKIGAP_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLTASUKIGAP_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLTASUKIGAP_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTHRUSTING( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLTHRUSTING(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLTHRUSTING_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLTHRUSTING( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLTHRUSTING", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTHRUSTING_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLTHRUSTING_StateInit(& _state)
    _ta_check_success("TA_CDLTHRUSTING_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTHRUSTING_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLTHRUSTING_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLTHRUSTING_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTHRUSTING_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLTHRUSTING_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLTHRUSTING_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLTHRUSTING_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTHRUSTING_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLTHRUSTING_StateFree( & _state )
    _ta_check_success("TA_CDLTHRUSTING_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTHRUSTING_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLTHRUSTING"
    _state = <void*> state
    retCode = lib.TA_CDLTHRUSTING_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLTHRUSTING_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTHRUSTING_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLTHRUSTING_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLTHRUSTING_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTRISTAR( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLTRISTAR(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLTRISTAR_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLTRISTAR( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLTRISTAR", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTRISTAR_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLTRISTAR_StateInit(& _state)
    _ta_check_success("TA_CDLTRISTAR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTRISTAR_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLTRISTAR_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLTRISTAR_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTRISTAR_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLTRISTAR_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLTRISTAR_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLTRISTAR_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTRISTAR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLTRISTAR_StateFree( & _state )
    _ta_check_success("TA_CDLTRISTAR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTRISTAR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLTRISTAR"
    _state = <void*> state
    retCode = lib.TA_CDLTRISTAR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLTRISTAR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLTRISTAR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLTRISTAR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLTRISTAR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUNIQUE3RIVER( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLUNIQUE3RIVER(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLUNIQUE3RIVER_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLUNIQUE3RIVER( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLUNIQUE3RIVER", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUNIQUE3RIVER_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLUNIQUE3RIVER_StateInit(& _state)
    _ta_check_success("TA_CDLUNIQUE3RIVER_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUNIQUE3RIVER_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLUNIQUE3RIVER_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLUNIQUE3RIVER_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUNIQUE3RIVER_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLUNIQUE3RIVER_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLUNIQUE3RIVER_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLUNIQUE3RIVER_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUNIQUE3RIVER_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLUNIQUE3RIVER_StateFree( & _state )
    _ta_check_success("TA_CDLUNIQUE3RIVER_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUNIQUE3RIVER_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLUNIQUE3RIVER"
    _state = <void*> state
    retCode = lib.TA_CDLUNIQUE3RIVER_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLUNIQUE3RIVER_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUNIQUE3RIVER_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLUNIQUE3RIVER_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLUNIQUE3RIVER_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUPSIDEGAP2CROWS( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLUPSIDEGAP2CROWS(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLUPSIDEGAP2CROWS_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLUPSIDEGAP2CROWS( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLUPSIDEGAP2CROWS", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUPSIDEGAP2CROWS_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLUPSIDEGAP2CROWS_StateInit(& _state)
    _ta_check_success("TA_CDLUPSIDEGAP2CROWS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUPSIDEGAP2CROWS_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLUPSIDEGAP2CROWS_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLUPSIDEGAP2CROWS_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUPSIDEGAP2CROWS_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLUPSIDEGAP2CROWS_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLUPSIDEGAP2CROWS_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLUPSIDEGAP2CROWS_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUPSIDEGAP2CROWS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLUPSIDEGAP2CROWS_StateFree( & _state )
    _ta_check_success("TA_CDLUPSIDEGAP2CROWS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUPSIDEGAP2CROWS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLUPSIDEGAP2CROWS"
    _state = <void*> state
    retCode = lib.TA_CDLUPSIDEGAP2CROWS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLUPSIDEGAP2CROWS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLUPSIDEGAP2CROWS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLUPSIDEGAP2CROWS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLUPSIDEGAP2CROWS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLXSIDEGAP3METHODS( np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLXSIDEGAP3METHODS(open, high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CDLXSIDEGAP3METHODS_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLXSIDEGAP3METHODS( 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLXSIDEGAP3METHODS", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLXSIDEGAP3METHODS_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLXSIDEGAP3METHODS_StateInit(& _state)
    _ta_check_success("TA_CDLXSIDEGAP3METHODS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLXSIDEGAP3METHODS_State( size_t state , double open , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_CDLXSIDEGAP3METHODS_State( _state , open , high , low , close , &outinteger )
    need_mode_data = not _ta_check_success("TA_CDLXSIDEGAP3METHODS_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLXSIDEGAP3METHODS_BatchState( size_t state , np.ndarray open not None , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ CDLXSIDEGAP3METHODS_BatchState(open, high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    open = check_array(open)
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length4(open, high, low, close)
    begidx = check_begidx4(length, <double*>(open.data), <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_CDLXSIDEGAP3METHODS_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_CDLXSIDEGAP3METHODS_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLXSIDEGAP3METHODS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CDLXSIDEGAP3METHODS_StateFree( & _state )
    _ta_check_success("TA_CDLXSIDEGAP3METHODS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLXSIDEGAP3METHODS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CDLXSIDEGAP3METHODS"
    _state = <void*> state
    retCode = lib.TA_CDLXSIDEGAP3METHODS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CDLXSIDEGAP3METHODS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CDLXSIDEGAP3METHODS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CDLXSIDEGAP3METHODS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CDLXSIDEGAP3METHODS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CEIL( np.ndarray real not None ):
    """ CEIL(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CEIL_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_CEIL( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_CEIL", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CEIL_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CEIL_StateInit(& _state)
    _ta_check_success("TA_CEIL_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CEIL_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_CEIL_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_CEIL_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CEIL_BatchState( size_t state , np.ndarray real not None ):
    """ CEIL_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_CEIL_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_CEIL_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CEIL_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CEIL_StateFree( & _state )
    _ta_check_success("TA_CEIL_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CEIL_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CEIL"
    _state = <void*> state
    retCode = lib.TA_CEIL_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CEIL_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CEIL_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CEIL_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CEIL_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CMO( np.ndarray real not None , int timeperiod=-2**31 ):
    """ CMO(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CMO_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_CMO( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_CMO", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CMO_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CMO_StateInit(& _state, timeperiod)
    _ta_check_success("TA_CMO_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CMO_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_CMO_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_CMO_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CMO_BatchState( size_t state , np.ndarray real not None ):
    """ CMO_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_CMO_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_CMO_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CMO_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CMO_StateFree( & _state )
    _ta_check_success("TA_CMO_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CMO_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CMO"
    _state = <void*> state
    retCode = lib.TA_CMO_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CMO_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CMO_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CMO_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CMO_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CORREL( np.ndarray real0 not None , np.ndarray real1 not None , int timeperiod=-2**31 ):
    """ CORREL(real0, real1[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_CORREL_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_CORREL( 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_CORREL", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CORREL_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CORREL_StateInit(& _state, timeperiod)
    _ta_check_success("TA_CORREL_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CORREL_State( size_t state , double real0 , double real1 ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_CORREL_State( _state , real0 , real1 , &outreal )
    need_mode_data = not _ta_check_success("TA_CORREL_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CORREL_BatchState( size_t state , np.ndarray real0 not None , np.ndarray real1 not None ):
    """ CORREL_BatchState(real0, real1)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_CORREL_BatchState( _state , 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_CORREL_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CORREL_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_CORREL_StateFree( & _state )
    _ta_check_success("TA_CORREL_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CORREL_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "CORREL"
    _state = <void*> state
    retCode = lib.TA_CORREL_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_CORREL_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def CORREL_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_CORREL_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_CORREL_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COS( np.ndarray real not None ):
    """ COS(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_COS_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_COS( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_COS", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COS_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_COS_StateInit(& _state)
    _ta_check_success("TA_COS_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COS_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_COS_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_COS_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COS_BatchState( size_t state , np.ndarray real not None ):
    """ COS_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_COS_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_COS_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COS_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_COS_StateFree( & _state )
    _ta_check_success("TA_COS_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COS_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "COS"
    _state = <void*> state
    retCode = lib.TA_COS_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_COS_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COS_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_COS_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_COS_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COSH( np.ndarray real not None ):
    """ COSH(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_COSH_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_COSH( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_COSH", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COSH_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_COSH_StateInit(& _state)
    _ta_check_success("TA_COSH_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COSH_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_COSH_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_COSH_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COSH_BatchState( size_t state , np.ndarray real not None ):
    """ COSH_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_COSH_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_COSH_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COSH_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_COSH_StateFree( & _state )
    _ta_check_success("TA_COSH_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COSH_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "COSH"
    _state = <void*> state
    retCode = lib.TA_COSH_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_COSH_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def COSH_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_COSH_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_COSH_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DEMA( np.ndarray real not None , int timeperiod=-2**31 ):
    """ DEMA(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_DEMA_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_DEMA( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_DEMA", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DEMA_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_DEMA_StateInit(& _state, timeperiod)
    _ta_check_success("TA_DEMA_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DEMA_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_DEMA_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_DEMA_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DEMA_BatchState( size_t state , np.ndarray real not None ):
    """ DEMA_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_DEMA_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_DEMA_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DEMA_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_DEMA_StateFree( & _state )
    _ta_check_success("TA_DEMA_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DEMA_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "DEMA"
    _state = <void*> state
    retCode = lib.TA_DEMA_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_DEMA_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DEMA_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_DEMA_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_DEMA_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DIV( np.ndarray real0 not None , np.ndarray real1 not None ):
    """ DIV(real0, real1)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_DIV_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_DIV( 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_DIV", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DIV_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_DIV_StateInit(& _state)
    _ta_check_success("TA_DIV_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DIV_State( size_t state , double real0 , double real1 ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_DIV_State( _state , real0 , real1 , &outreal )
    need_mode_data = not _ta_check_success("TA_DIV_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DIV_BatchState( size_t state , np.ndarray real0 not None , np.ndarray real1 not None ):
    """ DIV_BatchState(real0, real1)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_DIV_BatchState( _state , 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_DIV_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DIV_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_DIV_StateFree( & _state )
    _ta_check_success("TA_DIV_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DIV_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "DIV"
    _state = <void*> state
    retCode = lib.TA_DIV_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_DIV_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DIV_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_DIV_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_DIV_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DX( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ DX(high, low, close[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_DX_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_DX( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_DX", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DX_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_DX_StateInit(& _state, timeperiod)
    _ta_check_success("TA_DX_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DX_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_DX_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_DX_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DX_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ DX_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_DX_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_DX_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DX_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_DX_StateFree( & _state )
    _ta_check_success("TA_DX_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DX_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "DX"
    _state = <void*> state
    retCode = lib.TA_DX_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_DX_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def DX_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_DX_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_DX_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EMA( np.ndarray real not None , int timeperiod=-2**31 ):
    """ EMA(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_EMA_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_EMA( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_EMA", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EMA_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_EMA_StateInit(& _state, timeperiod)
    _ta_check_success("TA_EMA_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EMA_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_EMA_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_EMA_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EMA_BatchState( size_t state , np.ndarray real not None ):
    """ EMA_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_EMA_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_EMA_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EMA_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_EMA_StateFree( & _state )
    _ta_check_success("TA_EMA_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EMA_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "EMA"
    _state = <void*> state
    retCode = lib.TA_EMA_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_EMA_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EMA_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_EMA_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_EMA_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EXP( np.ndarray real not None ):
    """ EXP(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_EXP_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_EXP( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_EXP", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EXP_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_EXP_StateInit(& _state)
    _ta_check_success("TA_EXP_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EXP_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_EXP_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_EXP_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EXP_BatchState( size_t state , np.ndarray real not None ):
    """ EXP_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_EXP_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_EXP_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EXP_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_EXP_StateFree( & _state )
    _ta_check_success("TA_EXP_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EXP_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "EXP"
    _state = <void*> state
    retCode = lib.TA_EXP_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_EXP_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def EXP_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_EXP_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_EXP_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def FLOOR( np.ndarray real not None ):
    """ FLOOR(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_FLOOR_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_FLOOR( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_FLOOR", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def FLOOR_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_FLOOR_StateInit(& _state)
    _ta_check_success("TA_FLOOR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def FLOOR_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_FLOOR_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_FLOOR_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def FLOOR_BatchState( size_t state , np.ndarray real not None ):
    """ FLOOR_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_FLOOR_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_FLOOR_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def FLOOR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_FLOOR_StateFree( & _state )
    _ta_check_success("TA_FLOOR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def FLOOR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "FLOOR"
    _state = <void*> state
    retCode = lib.TA_FLOOR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_FLOOR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def FLOOR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_FLOOR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_FLOOR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPERIOD( np.ndarray real not None ):
    """ HT_DCPERIOD(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_HT_DCPERIOD_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_HT_DCPERIOD( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_HT_DCPERIOD", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPERIOD_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_DCPERIOD_StateInit(& _state)
    _ta_check_success("TA_HT_DCPERIOD_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPERIOD_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_HT_DCPERIOD_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_HT_DCPERIOD_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPERIOD_BatchState( size_t state , np.ndarray real not None ):
    """ HT_DCPERIOD_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_HT_DCPERIOD_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_HT_DCPERIOD_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPERIOD_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_HT_DCPERIOD_StateFree( & _state )
    _ta_check_success("TA_HT_DCPERIOD_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPERIOD_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "HT_DCPERIOD"
    _state = <void*> state
    retCode = lib.TA_HT_DCPERIOD_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_HT_DCPERIOD_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPERIOD_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_DCPERIOD_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_HT_DCPERIOD_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPHASE( np.ndarray real not None ):
    """ HT_DCPHASE(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_HT_DCPHASE_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_HT_DCPHASE( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_HT_DCPHASE", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPHASE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_DCPHASE_StateInit(& _state)
    _ta_check_success("TA_HT_DCPHASE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPHASE_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_HT_DCPHASE_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_HT_DCPHASE_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPHASE_BatchState( size_t state , np.ndarray real not None ):
    """ HT_DCPHASE_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_HT_DCPHASE_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_HT_DCPHASE_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPHASE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_HT_DCPHASE_StateFree( & _state )
    _ta_check_success("TA_HT_DCPHASE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPHASE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "HT_DCPHASE"
    _state = <void*> state
    retCode = lib.TA_HT_DCPHASE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_HT_DCPHASE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_DCPHASE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_DCPHASE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_HT_DCPHASE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_PHASOR( np.ndarray real not None ):
    """ HT_PHASOR(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinphase
        np.ndarray outquadrature
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_HT_PHASOR_Lookback( )
    outinphase = make_double_array(length, lookback)
    outquadrature = make_double_array(length, lookback)
    retCode = lib.TA_HT_PHASOR( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outinphase.data)+lookback , <double *>(outquadrature.data)+lookback )
    _ta_check_success("TA_HT_PHASOR", retCode)
    return TALibResult(retCode), outinphase , outquadrature 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_PHASOR_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_PHASOR_StateInit(& _state)
    _ta_check_success("TA_HT_PHASOR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_PHASOR_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outinphase
        double outquadrature
    _state = <void*>state
    retCode = lib.TA_HT_PHASOR_State( _state , real , &outinphase , &outquadrature )
    need_mode_data = not _ta_check_success("TA_HT_PHASOR_State", retCode)
    return TALibResult(retCode), outinphase , outquadrature 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_PHASOR_BatchState( size_t state , np.ndarray real not None ):
    """ HT_PHASOR_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinphase
        np.ndarray outquadrature
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinphase = make_double_array(length, lookback)
    outquadrature = make_double_array(length, lookback)
    retCode = lib.TA_HT_PHASOR_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outinphase.data)+lookback , <double *>(outquadrature.data)+lookback )
    _ta_check_success("TA_HT_PHASOR_BatchState", retCode)
    return TALibResult(retCode), outinphase , outquadrature 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_PHASOR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_HT_PHASOR_StateFree( & _state )
    _ta_check_success("TA_HT_PHASOR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_PHASOR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "HT_PHASOR"
    _state = <void*> state
    retCode = lib.TA_HT_PHASOR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_HT_PHASOR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_PHASOR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_PHASOR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_HT_PHASOR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_SINE( np.ndarray real not None ):
    """ HT_SINE(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outsine
        np.ndarray outleadsine
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_HT_SINE_Lookback( )
    outsine = make_double_array(length, lookback)
    outleadsine = make_double_array(length, lookback)
    retCode = lib.TA_HT_SINE( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outsine.data)+lookback , <double *>(outleadsine.data)+lookback )
    _ta_check_success("TA_HT_SINE", retCode)
    return TALibResult(retCode), outsine , outleadsine 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_SINE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_SINE_StateInit(& _state)
    _ta_check_success("TA_HT_SINE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_SINE_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outsine
        double outleadsine
    _state = <void*>state
    retCode = lib.TA_HT_SINE_State( _state , real , &outsine , &outleadsine )
    need_mode_data = not _ta_check_success("TA_HT_SINE_State", retCode)
    return TALibResult(retCode), outsine , outleadsine 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_SINE_BatchState( size_t state , np.ndarray real not None ):
    """ HT_SINE_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outsine
        np.ndarray outleadsine
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outsine = make_double_array(length, lookback)
    outleadsine = make_double_array(length, lookback)
    retCode = lib.TA_HT_SINE_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outsine.data)+lookback , <double *>(outleadsine.data)+lookback )
    _ta_check_success("TA_HT_SINE_BatchState", retCode)
    return TALibResult(retCode), outsine , outleadsine 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_SINE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_HT_SINE_StateFree( & _state )
    _ta_check_success("TA_HT_SINE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_SINE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "HT_SINE"
    _state = <void*> state
    retCode = lib.TA_HT_SINE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_HT_SINE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_SINE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_SINE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_HT_SINE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDLINE( np.ndarray real not None ):
    """ HT_TRENDLINE(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_HT_TRENDLINE_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_HT_TRENDLINE( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_HT_TRENDLINE", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDLINE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_TRENDLINE_StateInit(& _state)
    _ta_check_success("TA_HT_TRENDLINE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDLINE_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_HT_TRENDLINE_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_HT_TRENDLINE_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDLINE_BatchState( size_t state , np.ndarray real not None ):
    """ HT_TRENDLINE_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_HT_TRENDLINE_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_HT_TRENDLINE_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDLINE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_HT_TRENDLINE_StateFree( & _state )
    _ta_check_success("TA_HT_TRENDLINE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDLINE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "HT_TRENDLINE"
    _state = <void*> state
    retCode = lib.TA_HT_TRENDLINE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_HT_TRENDLINE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDLINE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_TRENDLINE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_HT_TRENDLINE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDMODE( np.ndarray real not None ):
    """ HT_TRENDMODE(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_HT_TRENDMODE_Lookback( )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_HT_TRENDMODE( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_HT_TRENDMODE", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDMODE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_TRENDMODE_StateInit(& _state)
    _ta_check_success("TA_HT_TRENDMODE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDMODE_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_HT_TRENDMODE_State( _state , real , &outinteger )
    need_mode_data = not _ta_check_success("TA_HT_TRENDMODE_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDMODE_BatchState( size_t state , np.ndarray real not None ):
    """ HT_TRENDMODE_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_HT_TRENDMODE_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_HT_TRENDMODE_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDMODE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_HT_TRENDMODE_StateFree( & _state )
    _ta_check_success("TA_HT_TRENDMODE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDMODE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "HT_TRENDMODE"
    _state = <void*> state
    retCode = lib.TA_HT_TRENDMODE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_HT_TRENDMODE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def HT_TRENDMODE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_HT_TRENDMODE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_HT_TRENDMODE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def IMI( np.ndarray open not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ IMI(open, close[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    open = check_array(open)
    close = check_array(close)
    length = check_length2(open, close)
    begidx = check_begidx2(length, <double*>(open.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_IMI_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_IMI( 0 , endidx , <double *>(open.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_IMI", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def IMI_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_IMI_StateInit(& _state, timeperiod)
    _ta_check_success("TA_IMI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def IMI_State( size_t state , double open , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_IMI_State( _state , open , close , &outreal )
    need_mode_data = not _ta_check_success("TA_IMI_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def IMI_BatchState( size_t state , np.ndarray open not None , np.ndarray close not None ):
    """ IMI_BatchState(open, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    open = check_array(open)
    close = check_array(close)
    length = check_length2(open, close)
    begidx = check_begidx2(length, <double*>(open.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_IMI_BatchState( _state , 0 , endidx , <double *>(open.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_IMI_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def IMI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_IMI_StateFree( & _state )
    _ta_check_success("TA_IMI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def IMI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "IMI"
    _state = <void*> state
    retCode = lib.TA_IMI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_IMI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def IMI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_IMI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_IMI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def KAMA( np.ndarray real not None , int timeperiod=-2**31 ):
    """ KAMA(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_KAMA_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_KAMA( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_KAMA", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def KAMA_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_KAMA_StateInit(& _state, timeperiod)
    _ta_check_success("TA_KAMA_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def KAMA_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_KAMA_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_KAMA_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def KAMA_BatchState( size_t state , np.ndarray real not None ):
    """ KAMA_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_KAMA_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_KAMA_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def KAMA_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_KAMA_StateFree( & _state )
    _ta_check_success("TA_KAMA_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def KAMA_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "KAMA"
    _state = <void*> state
    retCode = lib.TA_KAMA_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_KAMA_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def KAMA_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_KAMA_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_KAMA_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG( np.ndarray real not None , int timeperiod=-2**31 ):
    """ LINEARREG(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_LINEARREG_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LINEARREG( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LINEARREG", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LINEARREG_StateInit(& _state, timeperiod)
    _ta_check_success("TA_LINEARREG_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_LINEARREG_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_LINEARREG_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_BatchState( size_t state , np.ndarray real not None ):
    """ LINEARREG_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LINEARREG_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LINEARREG_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_LINEARREG_StateFree( & _state )
    _ta_check_success("TA_LINEARREG_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "LINEARREG"
    _state = <void*> state
    retCode = lib.TA_LINEARREG_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_LINEARREG_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LINEARREG_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_LINEARREG_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_ANGLE( np.ndarray real not None , int timeperiod=-2**31 ):
    """ LINEARREG_ANGLE(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_LINEARREG_ANGLE_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LINEARREG_ANGLE( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LINEARREG_ANGLE", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_ANGLE_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LINEARREG_ANGLE_StateInit(& _state, timeperiod)
    _ta_check_success("TA_LINEARREG_ANGLE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_ANGLE_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_LINEARREG_ANGLE_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_LINEARREG_ANGLE_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_ANGLE_BatchState( size_t state , np.ndarray real not None ):
    """ LINEARREG_ANGLE_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LINEARREG_ANGLE_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LINEARREG_ANGLE_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_ANGLE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_LINEARREG_ANGLE_StateFree( & _state )
    _ta_check_success("TA_LINEARREG_ANGLE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_ANGLE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "LINEARREG_ANGLE"
    _state = <void*> state
    retCode = lib.TA_LINEARREG_ANGLE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_LINEARREG_ANGLE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_ANGLE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LINEARREG_ANGLE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_LINEARREG_ANGLE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_INTERCEPT( np.ndarray real not None , int timeperiod=-2**31 ):
    """ LINEARREG_INTERCEPT(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_LINEARREG_INTERCEPT_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LINEARREG_INTERCEPT( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LINEARREG_INTERCEPT", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_INTERCEPT_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LINEARREG_INTERCEPT_StateInit(& _state, timeperiod)
    _ta_check_success("TA_LINEARREG_INTERCEPT_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_INTERCEPT_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_LINEARREG_INTERCEPT_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_LINEARREG_INTERCEPT_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_INTERCEPT_BatchState( size_t state , np.ndarray real not None ):
    """ LINEARREG_INTERCEPT_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LINEARREG_INTERCEPT_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LINEARREG_INTERCEPT_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_INTERCEPT_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_LINEARREG_INTERCEPT_StateFree( & _state )
    _ta_check_success("TA_LINEARREG_INTERCEPT_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_INTERCEPT_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "LINEARREG_INTERCEPT"
    _state = <void*> state
    retCode = lib.TA_LINEARREG_INTERCEPT_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_LINEARREG_INTERCEPT_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_INTERCEPT_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LINEARREG_INTERCEPT_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_LINEARREG_INTERCEPT_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_SLOPE( np.ndarray real not None , int timeperiod=-2**31 ):
    """ LINEARREG_SLOPE(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_LINEARREG_SLOPE_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LINEARREG_SLOPE( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LINEARREG_SLOPE", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_SLOPE_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LINEARREG_SLOPE_StateInit(& _state, timeperiod)
    _ta_check_success("TA_LINEARREG_SLOPE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_SLOPE_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_LINEARREG_SLOPE_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_LINEARREG_SLOPE_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_SLOPE_BatchState( size_t state , np.ndarray real not None ):
    """ LINEARREG_SLOPE_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LINEARREG_SLOPE_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LINEARREG_SLOPE_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_SLOPE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_LINEARREG_SLOPE_StateFree( & _state )
    _ta_check_success("TA_LINEARREG_SLOPE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_SLOPE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "LINEARREG_SLOPE"
    _state = <void*> state
    retCode = lib.TA_LINEARREG_SLOPE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_LINEARREG_SLOPE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LINEARREG_SLOPE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LINEARREG_SLOPE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_LINEARREG_SLOPE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LN( np.ndarray real not None ):
    """ LN(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_LN_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LN( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LN", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LN_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LN_StateInit(& _state)
    _ta_check_success("TA_LN_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LN_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_LN_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_LN_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LN_BatchState( size_t state , np.ndarray real not None ):
    """ LN_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LN_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LN_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LN_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_LN_StateFree( & _state )
    _ta_check_success("TA_LN_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LN_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "LN"
    _state = <void*> state
    retCode = lib.TA_LN_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_LN_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LN_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LN_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_LN_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LOG10( np.ndarray real not None ):
    """ LOG10(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_LOG10_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LOG10( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LOG10", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LOG10_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LOG10_StateInit(& _state)
    _ta_check_success("TA_LOG10_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LOG10_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_LOG10_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_LOG10_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LOG10_BatchState( size_t state , np.ndarray real not None ):
    """ LOG10_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_LOG10_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_LOG10_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LOG10_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_LOG10_StateFree( & _state )
    _ta_check_success("TA_LOG10_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LOG10_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "LOG10"
    _state = <void*> state
    retCode = lib.TA_LOG10_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_LOG10_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def LOG10_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_LOG10_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_LOG10_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MA( np.ndarray real not None , int timeperiod=-2**31 , int matype=0 ):
    """ MA(real[, timeperiod=?, matype=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MA_Lookback( timeperiod , matype )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MA( 0 , endidx , <double *>(real.data)+begidx , timeperiod , matype , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MA", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MA_StateInit( int timeperiod=-2**31 , int matype=0 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MA_StateInit(& _state, timeperiod, matype)
    _ta_check_success("TA_MA_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MA_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MA_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_MA_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MA_BatchState( size_t state , np.ndarray real not None ):
    """ MA_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MA_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MA_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MA_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MA_StateFree( & _state )
    _ta_check_success("TA_MA_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MA_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MA"
    _state = <void*> state
    retCode = lib.TA_MA_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MA_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MA_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MA_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MA_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACD( np.ndarray real not None , int fastperiod=-2**31 , int slowperiod=-2**31 , int signalperiod=-2**31 ):
    """ MACD(real[, fastperiod=?, slowperiod=?, signalperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmacd
        np.ndarray outmacdsignal
        np.ndarray outmacdhist
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MACD_Lookback( fastperiod , slowperiod , signalperiod )
    outmacd = make_double_array(length, lookback)
    outmacdsignal = make_double_array(length, lookback)
    outmacdhist = make_double_array(length, lookback)
    retCode = lib.TA_MACD( 0 , endidx , <double *>(real.data)+begidx , fastperiod , slowperiod , signalperiod , &outbegidx , &outnbelement , <double *>(outmacd.data)+lookback , <double *>(outmacdsignal.data)+lookback , <double *>(outmacdhist.data)+lookback )
    _ta_check_success("TA_MACD", retCode)
    return TALibResult(retCode), outmacd , outmacdsignal , outmacdhist 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACD_StateInit( int fastperiod=-2**31 , int slowperiod=-2**31 , int signalperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MACD_StateInit(& _state, fastperiod, slowperiod, signalperiod)
    _ta_check_success("TA_MACD_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACD_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outmacd
        double outmacdsignal
        double outmacdhist
    _state = <void*>state
    retCode = lib.TA_MACD_State( _state , real , &outmacd , &outmacdsignal , &outmacdhist )
    need_mode_data = not _ta_check_success("TA_MACD_State", retCode)
    return TALibResult(retCode), outmacd , outmacdsignal , outmacdhist 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACD_BatchState( size_t state , np.ndarray real not None ):
    """ MACD_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmacd
        np.ndarray outmacdsignal
        np.ndarray outmacdhist
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outmacd = make_double_array(length, lookback)
    outmacdsignal = make_double_array(length, lookback)
    outmacdhist = make_double_array(length, lookback)
    retCode = lib.TA_MACD_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outmacd.data)+lookback , <double *>(outmacdsignal.data)+lookback , <double *>(outmacdhist.data)+lookback )
    _ta_check_success("TA_MACD_BatchState", retCode)
    return TALibResult(retCode), outmacd , outmacdsignal , outmacdhist 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACD_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MACD_StateFree( & _state )
    _ta_check_success("TA_MACD_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACD_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MACD"
    _state = <void*> state
    retCode = lib.TA_MACD_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MACD_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACD_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MACD_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MACD_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDEXT( np.ndarray real not None , int fastperiod=-2**31 , int fastmatype=0 , int slowperiod=-2**31 , int slowmatype=0 , int signalperiod=-2**31 , int signalmatype=0 ):
    """ MACDEXT(real[, fastperiod=?, fastmatype=?, slowperiod=?, slowmatype=?, signalperiod=?, signalmatype=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmacd
        np.ndarray outmacdsignal
        np.ndarray outmacdhist
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MACDEXT_Lookback( fastperiod , fastmatype , slowperiod , slowmatype , signalperiod , signalmatype )
    outmacd = make_double_array(length, lookback)
    outmacdsignal = make_double_array(length, lookback)
    outmacdhist = make_double_array(length, lookback)
    retCode = lib.TA_MACDEXT( 0 , endidx , <double *>(real.data)+begidx , fastperiod , fastmatype , slowperiod , slowmatype , signalperiod , signalmatype , &outbegidx , &outnbelement , <double *>(outmacd.data)+lookback , <double *>(outmacdsignal.data)+lookback , <double *>(outmacdhist.data)+lookback )
    _ta_check_success("TA_MACDEXT", retCode)
    return TALibResult(retCode), outmacd , outmacdsignal , outmacdhist 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDEXT_StateInit( int fastperiod=-2**31 , int fastmatype=0 , int slowperiod=-2**31 , int slowmatype=0 , int signalperiod=-2**31 , int signalmatype=0 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MACDEXT_StateInit(& _state, fastperiod, fastmatype, slowperiod, slowmatype, signalperiod, signalmatype)
    _ta_check_success("TA_MACDEXT_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDEXT_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outmacd
        double outmacdsignal
        double outmacdhist
    _state = <void*>state
    retCode = lib.TA_MACDEXT_State( _state , real , &outmacd , &outmacdsignal , &outmacdhist )
    need_mode_data = not _ta_check_success("TA_MACDEXT_State", retCode)
    return TALibResult(retCode), outmacd , outmacdsignal , outmacdhist 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDEXT_BatchState( size_t state , np.ndarray real not None ):
    """ MACDEXT_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmacd
        np.ndarray outmacdsignal
        np.ndarray outmacdhist
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outmacd = make_double_array(length, lookback)
    outmacdsignal = make_double_array(length, lookback)
    outmacdhist = make_double_array(length, lookback)
    retCode = lib.TA_MACDEXT_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outmacd.data)+lookback , <double *>(outmacdsignal.data)+lookback , <double *>(outmacdhist.data)+lookback )
    _ta_check_success("TA_MACDEXT_BatchState", retCode)
    return TALibResult(retCode), outmacd , outmacdsignal , outmacdhist 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDEXT_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MACDEXT_StateFree( & _state )
    _ta_check_success("TA_MACDEXT_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDEXT_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MACDEXT"
    _state = <void*> state
    retCode = lib.TA_MACDEXT_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MACDEXT_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDEXT_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MACDEXT_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MACDEXT_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDFIX( np.ndarray real not None , int signalperiod=-2**31 ):
    """ MACDFIX(real[, signalperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmacd
        np.ndarray outmacdsignal
        np.ndarray outmacdhist
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MACDFIX_Lookback( signalperiod )
    outmacd = make_double_array(length, lookback)
    outmacdsignal = make_double_array(length, lookback)
    outmacdhist = make_double_array(length, lookback)
    retCode = lib.TA_MACDFIX( 0 , endidx , <double *>(real.data)+begidx , signalperiod , &outbegidx , &outnbelement , <double *>(outmacd.data)+lookback , <double *>(outmacdsignal.data)+lookback , <double *>(outmacdhist.data)+lookback )
    _ta_check_success("TA_MACDFIX", retCode)
    return TALibResult(retCode), outmacd , outmacdsignal , outmacdhist 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDFIX_StateInit( int signalperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MACDFIX_StateInit(& _state, signalperiod)
    _ta_check_success("TA_MACDFIX_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDFIX_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outmacd
        double outmacdsignal
        double outmacdhist
    _state = <void*>state
    retCode = lib.TA_MACDFIX_State( _state , real , &outmacd , &outmacdsignal , &outmacdhist )
    need_mode_data = not _ta_check_success("TA_MACDFIX_State", retCode)
    return TALibResult(retCode), outmacd , outmacdsignal , outmacdhist 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDFIX_BatchState( size_t state , np.ndarray real not None ):
    """ MACDFIX_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmacd
        np.ndarray outmacdsignal
        np.ndarray outmacdhist
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outmacd = make_double_array(length, lookback)
    outmacdsignal = make_double_array(length, lookback)
    outmacdhist = make_double_array(length, lookback)
    retCode = lib.TA_MACDFIX_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outmacd.data)+lookback , <double *>(outmacdsignal.data)+lookback , <double *>(outmacdhist.data)+lookback )
    _ta_check_success("TA_MACDFIX_BatchState", retCode)
    return TALibResult(retCode), outmacd , outmacdsignal , outmacdhist 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDFIX_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MACDFIX_StateFree( & _state )
    _ta_check_success("TA_MACDFIX_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDFIX_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MACDFIX"
    _state = <void*> state
    retCode = lib.TA_MACDFIX_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MACDFIX_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MACDFIX_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MACDFIX_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MACDFIX_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAMA( np.ndarray real not None , double fastlimit=-4e37 , double slowlimit=-4e37 ):
    """ MAMA(real[, fastlimit=?, slowlimit=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmama
        np.ndarray outfama
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MAMA_Lookback( fastlimit , slowlimit )
    outmama = make_double_array(length, lookback)
    outfama = make_double_array(length, lookback)
    retCode = lib.TA_MAMA( 0 , endidx , <double *>(real.data)+begidx , fastlimit , slowlimit , &outbegidx , &outnbelement , <double *>(outmama.data)+lookback , <double *>(outfama.data)+lookback )
    _ta_check_success("TA_MAMA", retCode)
    return TALibResult(retCode), outmama , outfama 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAMA_StateInit( double fastlimit=-4e37 , double slowlimit=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MAMA_StateInit(& _state, fastlimit, slowlimit)
    _ta_check_success("TA_MAMA_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAMA_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outmama
        double outfama
    _state = <void*>state
    retCode = lib.TA_MAMA_State( _state , real , &outmama , &outfama )
    need_mode_data = not _ta_check_success("TA_MAMA_State", retCode)
    return TALibResult(retCode), outmama , outfama 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAMA_BatchState( size_t state , np.ndarray real not None ):
    """ MAMA_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmama
        np.ndarray outfama
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outmama = make_double_array(length, lookback)
    outfama = make_double_array(length, lookback)
    retCode = lib.TA_MAMA_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outmama.data)+lookback , <double *>(outfama.data)+lookback )
    _ta_check_success("TA_MAMA_BatchState", retCode)
    return TALibResult(retCode), outmama , outfama 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAMA_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MAMA_StateFree( & _state )
    _ta_check_success("TA_MAMA_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAMA_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MAMA"
    _state = <void*> state
    retCode = lib.TA_MAMA_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MAMA_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAMA_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MAMA_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MAMA_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAVP( np.ndarray real not None , np.ndarray periods not None , int minperiod=-2**31 , int maxperiod=-2**31 , int matype=0 ):
    """ MAVP(real, periods[, minperiod=?, maxperiod=?, matype=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    periods = check_array(periods)
    length = check_length2(real, periods)
    begidx = check_begidx2(length, <double*>(real.data), <double*>(periods.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MAVP_Lookback( minperiod , maxperiod , matype )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MAVP( 0 , endidx , <double *>(real.data)+begidx , <double *>(periods.data)+begidx , minperiod , maxperiod , matype , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MAVP", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAVP_StateInit( int minperiod=-2**31 , int maxperiod=-2**31 , int matype=0 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MAVP_StateInit(& _state, minperiod, maxperiod, matype)
    _ta_check_success("TA_MAVP_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAVP_State( size_t state , double real , double periods ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MAVP_State( _state , real , periods , &outreal )
    need_mode_data = not _ta_check_success("TA_MAVP_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAVP_BatchState( size_t state , np.ndarray real not None , np.ndarray periods not None ):
    """ MAVP_BatchState(real, periods)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    periods = check_array(periods)
    length = check_length2(real, periods)
    begidx = check_begidx2(length, <double*>(real.data), <double*>(periods.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MAVP_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , <double *>(periods.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MAVP_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAVP_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MAVP_StateFree( & _state )
    _ta_check_success("TA_MAVP_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAVP_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MAVP"
    _state = <void*> state
    retCode = lib.TA_MAVP_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MAVP_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAVP_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MAVP_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MAVP_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAX( np.ndarray real not None , int timeperiod=-2**31 ):
    """ MAX(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MAX_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MAX( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MAX", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAX_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MAX_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MAX_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAX_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MAX_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_MAX_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAX_BatchState( size_t state , np.ndarray real not None ):
    """ MAX_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MAX_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MAX_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAX_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MAX_StateFree( & _state )
    _ta_check_success("TA_MAX_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAX_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MAX"
    _state = <void*> state
    retCode = lib.TA_MAX_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MAX_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAX_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MAX_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MAX_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAXINDEX( np.ndarray real not None , int timeperiod=-2**31 ):
    """ MAXINDEX(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MAXINDEX_Lookback( timeperiod )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_MAXINDEX( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_MAXINDEX", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAXINDEX_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MAXINDEX_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MAXINDEX_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAXINDEX_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_MAXINDEX_State( _state , real , &outinteger )
    need_mode_data = not _ta_check_success("TA_MAXINDEX_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAXINDEX_BatchState( size_t state , np.ndarray real not None ):
    """ MAXINDEX_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_MAXINDEX_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_MAXINDEX_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAXINDEX_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MAXINDEX_StateFree( & _state )
    _ta_check_success("TA_MAXINDEX_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAXINDEX_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MAXINDEX"
    _state = <void*> state
    retCode = lib.TA_MAXINDEX_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MAXINDEX_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MAXINDEX_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MAXINDEX_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MAXINDEX_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MEDPRICE( np.ndarray high not None , np.ndarray low not None ):
    """ MEDPRICE(high, low)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MEDPRICE_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MEDPRICE( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MEDPRICE", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MEDPRICE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MEDPRICE_StateInit(& _state)
    _ta_check_success("TA_MEDPRICE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MEDPRICE_State( size_t state , double high , double low ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MEDPRICE_State( _state , high , low , &outreal )
    need_mode_data = not _ta_check_success("TA_MEDPRICE_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MEDPRICE_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None ):
    """ MEDPRICE_BatchState(high, low)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MEDPRICE_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MEDPRICE_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MEDPRICE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MEDPRICE_StateFree( & _state )
    _ta_check_success("TA_MEDPRICE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MEDPRICE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MEDPRICE"
    _state = <void*> state
    retCode = lib.TA_MEDPRICE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MEDPRICE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MEDPRICE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MEDPRICE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MEDPRICE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MFI( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , np.ndarray volume not None , int timeperiod=-2**31 ):
    """ MFI(high, low, close, volume[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    volume = check_array(volume)
    length = check_length4(high, low, close, volume)
    begidx = check_begidx4(length, <double*>(high.data), <double*>(low.data), <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MFI_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MFI( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MFI", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MFI_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MFI_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MFI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MFI_State( size_t state , double high , double low , double close , double volume ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MFI_State( _state , high , low , close , volume , &outreal )
    need_mode_data = not _ta_check_success("TA_MFI_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MFI_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , np.ndarray volume not None ):
    """ MFI_BatchState(high, low, close, volume)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    volume = check_array(volume)
    length = check_length4(high, low, close, volume)
    begidx = check_begidx4(length, <double*>(high.data), <double*>(low.data), <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MFI_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MFI_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MFI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MFI_StateFree( & _state )
    _ta_check_success("TA_MFI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MFI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MFI"
    _state = <void*> state
    retCode = lib.TA_MFI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MFI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MFI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MFI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MFI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPOINT( np.ndarray real not None , int timeperiod=-2**31 ):
    """ MIDPOINT(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MIDPOINT_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MIDPOINT( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MIDPOINT", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPOINT_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MIDPOINT_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MIDPOINT_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPOINT_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MIDPOINT_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_MIDPOINT_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPOINT_BatchState( size_t state , np.ndarray real not None ):
    """ MIDPOINT_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MIDPOINT_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MIDPOINT_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPOINT_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MIDPOINT_StateFree( & _state )
    _ta_check_success("TA_MIDPOINT_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPOINT_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MIDPOINT"
    _state = <void*> state
    retCode = lib.TA_MIDPOINT_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MIDPOINT_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPOINT_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MIDPOINT_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MIDPOINT_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPRICE( np.ndarray high not None , np.ndarray low not None , int timeperiod=-2**31 ):
    """ MIDPRICE(high, low[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MIDPRICE_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MIDPRICE( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MIDPRICE", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPRICE_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MIDPRICE_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MIDPRICE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPRICE_State( size_t state , double high , double low ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MIDPRICE_State( _state , high , low , &outreal )
    need_mode_data = not _ta_check_success("TA_MIDPRICE_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPRICE_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None ):
    """ MIDPRICE_BatchState(high, low)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MIDPRICE_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MIDPRICE_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPRICE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MIDPRICE_StateFree( & _state )
    _ta_check_success("TA_MIDPRICE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPRICE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MIDPRICE"
    _state = <void*> state
    retCode = lib.TA_MIDPRICE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MIDPRICE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIDPRICE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MIDPRICE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MIDPRICE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIN( np.ndarray real not None , int timeperiod=-2**31 ):
    """ MIN(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MIN_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MIN( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MIN", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIN_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MIN_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MIN_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIN_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MIN_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_MIN_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIN_BatchState( size_t state , np.ndarray real not None ):
    """ MIN_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MIN_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MIN_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIN_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MIN_StateFree( & _state )
    _ta_check_success("TA_MIN_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIN_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MIN"
    _state = <void*> state
    retCode = lib.TA_MIN_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MIN_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MIN_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MIN_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MIN_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MININDEX( np.ndarray real not None , int timeperiod=-2**31 ):
    """ MININDEX(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MININDEX_Lookback( timeperiod )
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_MININDEX( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_MININDEX", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MININDEX_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MININDEX_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MININDEX_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MININDEX_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outinteger
    _state = <void*>state
    retCode = lib.TA_MININDEX_State( _state , real , &outinteger )
    need_mode_data = not _ta_check_success("TA_MININDEX_State", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MININDEX_BatchState( size_t state , np.ndarray real not None ):
    """ MININDEX_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outinteger
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outinteger = make_int_array(length, lookback)
    retCode = lib.TA_MININDEX_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <int *>(outinteger.data)+lookback )
    _ta_check_success("TA_MININDEX_BatchState", retCode)
    return TALibResult(retCode), outinteger 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MININDEX_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MININDEX_StateFree( & _state )
    _ta_check_success("TA_MININDEX_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MININDEX_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MININDEX"
    _state = <void*> state
    retCode = lib.TA_MININDEX_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MININDEX_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MININDEX_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MININDEX_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MININDEX_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAX( np.ndarray real not None , int timeperiod=-2**31 ):
    """ MINMAX(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmin
        np.ndarray outmax
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MINMAX_Lookback( timeperiod )
    outmin = make_double_array(length, lookback)
    outmax = make_double_array(length, lookback)
    retCode = lib.TA_MINMAX( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outmin.data)+lookback , <double *>(outmax.data)+lookback )
    _ta_check_success("TA_MINMAX", retCode)
    return TALibResult(retCode), outmin , outmax 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAX_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MINMAX_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MINMAX_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAX_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outmin
        double outmax
    _state = <void*>state
    retCode = lib.TA_MINMAX_State( _state , real , &outmin , &outmax )
    need_mode_data = not _ta_check_success("TA_MINMAX_State", retCode)
    return TALibResult(retCode), outmin , outmax 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAX_BatchState( size_t state , np.ndarray real not None ):
    """ MINMAX_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outmin
        np.ndarray outmax
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outmin = make_double_array(length, lookback)
    outmax = make_double_array(length, lookback)
    retCode = lib.TA_MINMAX_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outmin.data)+lookback , <double *>(outmax.data)+lookback )
    _ta_check_success("TA_MINMAX_BatchState", retCode)
    return TALibResult(retCode), outmin , outmax 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAX_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MINMAX_StateFree( & _state )
    _ta_check_success("TA_MINMAX_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAX_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MINMAX"
    _state = <void*> state
    retCode = lib.TA_MINMAX_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MINMAX_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAX_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MINMAX_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MINMAX_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAXINDEX( np.ndarray real not None , int timeperiod=-2**31 ):
    """ MINMAXINDEX(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outminidx
        np.ndarray outmaxidx
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MINMAXINDEX_Lookback( timeperiod )
    outminidx = make_int_array(length, lookback)
    outmaxidx = make_int_array(length, lookback)
    retCode = lib.TA_MINMAXINDEX( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <int *>(outminidx.data)+lookback , <int *>(outmaxidx.data)+lookback )
    _ta_check_success("TA_MINMAXINDEX", retCode)
    return TALibResult(retCode), outminidx , outmaxidx 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAXINDEX_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MINMAXINDEX_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MINMAXINDEX_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAXINDEX_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        int outminidx
        int outmaxidx
    _state = <void*>state
    retCode = lib.TA_MINMAXINDEX_State( _state , real , &outminidx , &outmaxidx )
    need_mode_data = not _ta_check_success("TA_MINMAXINDEX_State", retCode)
    return TALibResult(retCode), outminidx , outmaxidx 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAXINDEX_BatchState( size_t state , np.ndarray real not None ):
    """ MINMAXINDEX_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outminidx
        np.ndarray outmaxidx
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outminidx = make_int_array(length, lookback)
    outmaxidx = make_int_array(length, lookback)
    retCode = lib.TA_MINMAXINDEX_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <int *>(outminidx.data)+lookback , <int *>(outmaxidx.data)+lookback )
    _ta_check_success("TA_MINMAXINDEX_BatchState", retCode)
    return TALibResult(retCode), outminidx , outmaxidx 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAXINDEX_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MINMAXINDEX_StateFree( & _state )
    _ta_check_success("TA_MINMAXINDEX_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAXINDEX_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MINMAXINDEX"
    _state = <void*> state
    retCode = lib.TA_MINMAXINDEX_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MINMAXINDEX_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINMAXINDEX_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MINMAXINDEX_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MINMAXINDEX_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DI( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ MINUS_DI(high, low, close[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MINUS_DI_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MINUS_DI( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MINUS_DI", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DI_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MINUS_DI_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MINUS_DI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DI_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MINUS_DI_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_MINUS_DI_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DI_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ MINUS_DI_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MINUS_DI_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MINUS_DI_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MINUS_DI_StateFree( & _state )
    _ta_check_success("TA_MINUS_DI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MINUS_DI"
    _state = <void*> state
    retCode = lib.TA_MINUS_DI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MINUS_DI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MINUS_DI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MINUS_DI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DM( np.ndarray high not None , np.ndarray low not None , int timeperiod=-2**31 ):
    """ MINUS_DM(high, low[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MINUS_DM_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MINUS_DM( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MINUS_DM", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DM_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MINUS_DM_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MINUS_DM_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DM_State( size_t state , double high , double low ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MINUS_DM_State( _state , high , low , &outreal )
    need_mode_data = not _ta_check_success("TA_MINUS_DM_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DM_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None ):
    """ MINUS_DM_BatchState(high, low)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MINUS_DM_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MINUS_DM_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DM_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MINUS_DM_StateFree( & _state )
    _ta_check_success("TA_MINUS_DM_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DM_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MINUS_DM"
    _state = <void*> state
    retCode = lib.TA_MINUS_DM_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MINUS_DM_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MINUS_DM_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MINUS_DM_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MINUS_DM_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MOM( np.ndarray real not None , int timeperiod=-2**31 ):
    """ MOM(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MOM_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MOM( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MOM", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MOM_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MOM_StateInit(& _state, timeperiod)
    _ta_check_success("TA_MOM_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MOM_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MOM_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_MOM_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MOM_BatchState( size_t state , np.ndarray real not None ):
    """ MOM_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MOM_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MOM_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MOM_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MOM_StateFree( & _state )
    _ta_check_success("TA_MOM_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MOM_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MOM"
    _state = <void*> state
    retCode = lib.TA_MOM_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MOM_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MOM_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MOM_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MOM_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MULT( np.ndarray real0 not None , np.ndarray real1 not None ):
    """ MULT(real0, real1)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_MULT_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MULT( 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MULT", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MULT_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MULT_StateInit(& _state)
    _ta_check_success("TA_MULT_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MULT_State( size_t state , double real0 , double real1 ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_MULT_State( _state , real0 , real1 , &outreal )
    need_mode_data = not _ta_check_success("TA_MULT_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MULT_BatchState( size_t state , np.ndarray real0 not None , np.ndarray real1 not None ):
    """ MULT_BatchState(real0, real1)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_MULT_BatchState( _state , 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_MULT_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MULT_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_MULT_StateFree( & _state )
    _ta_check_success("TA_MULT_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MULT_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "MULT"
    _state = <void*> state
    retCode = lib.TA_MULT_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_MULT_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def MULT_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_MULT_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_MULT_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NATR( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ NATR(high, low, close[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_NATR_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_NATR( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_NATR", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NATR_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_NATR_StateInit(& _state, timeperiod)
    _ta_check_success("TA_NATR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NATR_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_NATR_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_NATR_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NATR_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ NATR_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_NATR_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_NATR_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NATR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_NATR_StateFree( & _state )
    _ta_check_success("TA_NATR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NATR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "NATR"
    _state = <void*> state
    retCode = lib.TA_NATR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_NATR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NATR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_NATR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_NATR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NVI( np.ndarray close not None , np.ndarray volume not None ):
    """ NVI(close, volume)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    close = check_array(close)
    volume = check_array(volume)
    length = check_length2(close, volume)
    begidx = check_begidx2(length, <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_NVI_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_NVI( 0 , endidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_NVI", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NVI_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_NVI_StateInit(& _state)
    _ta_check_success("TA_NVI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NVI_State( size_t state , double close , double volume ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_NVI_State( _state , close , volume , &outreal )
    need_mode_data = not _ta_check_success("TA_NVI_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NVI_BatchState( size_t state , np.ndarray close not None , np.ndarray volume not None ):
    """ NVI_BatchState(close, volume)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    close = check_array(close)
    volume = check_array(volume)
    length = check_length2(close, volume)
    begidx = check_begidx2(length, <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_NVI_BatchState( _state , 0 , endidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_NVI_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NVI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_NVI_StateFree( & _state )
    _ta_check_success("TA_NVI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NVI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "NVI"
    _state = <void*> state
    retCode = lib.TA_NVI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_NVI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def NVI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_NVI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_NVI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def OBV( np.ndarray close not None , np.ndarray volume not None ):
    """ OBV(close, volume)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    close = check_array(close)
    volume = check_array(volume)
    length = check_length2(close, volume)
    begidx = check_begidx2(length, <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_OBV_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_OBV( 0 , endidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_OBV", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def OBV_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_OBV_StateInit(& _state)
    _ta_check_success("TA_OBV_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def OBV_State( size_t state , double close , double volume ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_OBV_State( _state , close , volume , &outreal )
    need_mode_data = not _ta_check_success("TA_OBV_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def OBV_BatchState( size_t state , np.ndarray close not None , np.ndarray volume not None ):
    """ OBV_BatchState(close, volume)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    close = check_array(close)
    volume = check_array(volume)
    length = check_length2(close, volume)
    begidx = check_begidx2(length, <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_OBV_BatchState( _state , 0 , endidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_OBV_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def OBV_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_OBV_StateFree( & _state )
    _ta_check_success("TA_OBV_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def OBV_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "OBV"
    _state = <void*> state
    retCode = lib.TA_OBV_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_OBV_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def OBV_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_OBV_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_OBV_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DI( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ PLUS_DI(high, low, close[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_PLUS_DI_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PLUS_DI( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PLUS_DI", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DI_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_PLUS_DI_StateInit(& _state, timeperiod)
    _ta_check_success("TA_PLUS_DI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DI_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_PLUS_DI_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_PLUS_DI_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DI_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ PLUS_DI_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PLUS_DI_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PLUS_DI_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_PLUS_DI_StateFree( & _state )
    _ta_check_success("TA_PLUS_DI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "PLUS_DI"
    _state = <void*> state
    retCode = lib.TA_PLUS_DI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_PLUS_DI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_PLUS_DI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_PLUS_DI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DM( np.ndarray high not None , np.ndarray low not None , int timeperiod=-2**31 ):
    """ PLUS_DM(high, low[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_PLUS_DM_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PLUS_DM( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PLUS_DM", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DM_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_PLUS_DM_StateInit(& _state, timeperiod)
    _ta_check_success("TA_PLUS_DM_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DM_State( size_t state , double high , double low ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_PLUS_DM_State( _state , high , low , &outreal )
    need_mode_data = not _ta_check_success("TA_PLUS_DM_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DM_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None ):
    """ PLUS_DM_BatchState(high, low)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PLUS_DM_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PLUS_DM_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DM_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_PLUS_DM_StateFree( & _state )
    _ta_check_success("TA_PLUS_DM_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DM_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "PLUS_DM"
    _state = <void*> state
    retCode = lib.TA_PLUS_DM_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_PLUS_DM_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PLUS_DM_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_PLUS_DM_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_PLUS_DM_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PPO( np.ndarray real not None , int fastperiod=-2**31 , int slowperiod=-2**31 , int matype=0 ):
    """ PPO(real[, fastperiod=?, slowperiod=?, matype=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_PPO_Lookback( fastperiod , slowperiod , matype )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PPO( 0 , endidx , <double *>(real.data)+begidx , fastperiod , slowperiod , matype , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PPO", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PPO_StateInit( int fastperiod=-2**31 , int slowperiod=-2**31 , int matype=0 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_PPO_StateInit(& _state, fastperiod, slowperiod, matype)
    _ta_check_success("TA_PPO_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PPO_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_PPO_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_PPO_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PPO_BatchState( size_t state , np.ndarray real not None ):
    """ PPO_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PPO_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PPO_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PPO_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_PPO_StateFree( & _state )
    _ta_check_success("TA_PPO_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PPO_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "PPO"
    _state = <void*> state
    retCode = lib.TA_PPO_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_PPO_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PPO_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_PPO_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_PPO_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVI( np.ndarray close not None , np.ndarray volume not None ):
    """ PVI(close, volume)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    close = check_array(close)
    volume = check_array(volume)
    length = check_length2(close, volume)
    begidx = check_begidx2(length, <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_PVI_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PVI( 0 , endidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PVI", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVI_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_PVI_StateInit(& _state)
    _ta_check_success("TA_PVI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVI_State( size_t state , double close , double volume ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_PVI_State( _state , close , volume , &outreal )
    need_mode_data = not _ta_check_success("TA_PVI_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVI_BatchState( size_t state , np.ndarray close not None , np.ndarray volume not None ):
    """ PVI_BatchState(close, volume)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    close = check_array(close)
    volume = check_array(volume)
    length = check_length2(close, volume)
    begidx = check_begidx2(length, <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PVI_BatchState( _state , 0 , endidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PVI_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_PVI_StateFree( & _state )
    _ta_check_success("TA_PVI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "PVI"
    _state = <void*> state
    retCode = lib.TA_PVI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_PVI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_PVI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_PVI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVT( np.ndarray close not None , np.ndarray volume not None ):
    """ PVT(close, volume)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    close = check_array(close)
    volume = check_array(volume)
    length = check_length2(close, volume)
    begidx = check_begidx2(length, <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_PVT_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PVT( 0 , endidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PVT", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVT_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_PVT_StateInit(& _state)
    _ta_check_success("TA_PVT_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVT_State( size_t state , double close , double volume ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_PVT_State( _state , close , volume , &outreal )
    need_mode_data = not _ta_check_success("TA_PVT_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVT_BatchState( size_t state , np.ndarray close not None , np.ndarray volume not None ):
    """ PVT_BatchState(close, volume)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    close = check_array(close)
    volume = check_array(volume)
    length = check_length2(close, volume)
    begidx = check_begidx2(length, <double*>(close.data), <double*>(volume.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_PVT_BatchState( _state , 0 , endidx , <double *>(close.data)+begidx , <double *>(volume.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_PVT_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVT_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_PVT_StateFree( & _state )
    _ta_check_success("TA_PVT_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVT_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "PVT"
    _state = <void*> state
    retCode = lib.TA_PVT_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_PVT_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def PVT_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_PVT_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_PVT_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROC( np.ndarray real not None , int timeperiod=-2**31 ):
    """ ROC(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ROC_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ROC( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ROC", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROC_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ROC_StateInit(& _state, timeperiod)
    _ta_check_success("TA_ROC_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROC_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ROC_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_ROC_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROC_BatchState( size_t state , np.ndarray real not None ):
    """ ROC_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ROC_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ROC_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROC_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ROC_StateFree( & _state )
    _ta_check_success("TA_ROC_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROC_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ROC"
    _state = <void*> state
    retCode = lib.TA_ROC_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ROC_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROC_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ROC_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ROC_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCP( np.ndarray real not None , int timeperiod=-2**31 ):
    """ ROCP(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ROCP_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ROCP( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ROCP", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCP_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ROCP_StateInit(& _state, timeperiod)
    _ta_check_success("TA_ROCP_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCP_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ROCP_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_ROCP_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCP_BatchState( size_t state , np.ndarray real not None ):
    """ ROCP_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ROCP_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ROCP_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCP_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ROCP_StateFree( & _state )
    _ta_check_success("TA_ROCP_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCP_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ROCP"
    _state = <void*> state
    retCode = lib.TA_ROCP_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ROCP_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCP_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ROCP_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ROCP_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR( np.ndarray real not None , int timeperiod=-2**31 ):
    """ ROCR(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ROCR_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ROCR( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ROCR", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ROCR_StateInit(& _state, timeperiod)
    _ta_check_success("TA_ROCR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ROCR_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_ROCR_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR_BatchState( size_t state , np.ndarray real not None ):
    """ ROCR_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ROCR_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ROCR_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ROCR_StateFree( & _state )
    _ta_check_success("TA_ROCR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ROCR"
    _state = <void*> state
    retCode = lib.TA_ROCR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ROCR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ROCR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ROCR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR100( np.ndarray real not None , int timeperiod=-2**31 ):
    """ ROCR100(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ROCR100_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ROCR100( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ROCR100", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR100_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ROCR100_StateInit(& _state, timeperiod)
    _ta_check_success("TA_ROCR100_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR100_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ROCR100_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_ROCR100_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR100_BatchState( size_t state , np.ndarray real not None ):
    """ ROCR100_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ROCR100_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ROCR100_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR100_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ROCR100_StateFree( & _state )
    _ta_check_success("TA_ROCR100_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR100_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ROCR100"
    _state = <void*> state
    retCode = lib.TA_ROCR100_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ROCR100_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ROCR100_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ROCR100_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ROCR100_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def RSI( np.ndarray real not None , int timeperiod=-2**31 ):
    """ RSI(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_RSI_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_RSI( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_RSI", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def RSI_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_RSI_StateInit(& _state, timeperiod)
    _ta_check_success("TA_RSI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def RSI_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_RSI_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_RSI_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def RSI_BatchState( size_t state , np.ndarray real not None ):
    """ RSI_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_RSI_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_RSI_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def RSI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_RSI_StateFree( & _state )
    _ta_check_success("TA_RSI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def RSI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "RSI"
    _state = <void*> state
    retCode = lib.TA_RSI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_RSI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def RSI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_RSI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_RSI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAR( np.ndarray high not None , np.ndarray low not None , double acceleration=-4e37 , double maximum=-4e37 ):
    """ SAR(high, low[, acceleration=?, maximum=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_SAR_Lookback( acceleration , maximum )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SAR( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , acceleration , maximum , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SAR", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAR_StateInit( double acceleration=-4e37 , double maximum=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SAR_StateInit(& _state, acceleration, maximum)
    _ta_check_success("TA_SAR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAR_State( size_t state , double high , double low ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_SAR_State( _state , high , low , &outreal )
    need_mode_data = not _ta_check_success("TA_SAR_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAR_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None ):
    """ SAR_BatchState(high, low)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SAR_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SAR_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_SAR_StateFree( & _state )
    _ta_check_success("TA_SAR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "SAR"
    _state = <void*> state
    retCode = lib.TA_SAR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_SAR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SAR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_SAR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAREXT( np.ndarray high not None , np.ndarray low not None , double startvalue=-4e37 , double offsetonreverse=-4e37 , double accelerationinitlong=-4e37 , double accelerationlong=-4e37 , double accelerationmaxlong=-4e37 , double accelerationinitshort=-4e37 , double accelerationshort=-4e37 , double accelerationmaxshort=-4e37 ):
    """ SAREXT(high, low[, startvalue=?, offsetonreverse=?, accelerationinitlong=?, accelerationlong=?, accelerationmaxlong=?, accelerationinitshort=?, accelerationshort=?, accelerationmaxshort=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_SAREXT_Lookback( startvalue , offsetonreverse , accelerationinitlong , accelerationlong , accelerationmaxlong , accelerationinitshort , accelerationshort , accelerationmaxshort )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SAREXT( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , startvalue , offsetonreverse , accelerationinitlong , accelerationlong , accelerationmaxlong , accelerationinitshort , accelerationshort , accelerationmaxshort , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SAREXT", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAREXT_StateInit( double startvalue=-4e37 , double offsetonreverse=-4e37 , double accelerationinitlong=-4e37 , double accelerationlong=-4e37 , double accelerationmaxlong=-4e37 , double accelerationinitshort=-4e37 , double accelerationshort=-4e37 , double accelerationmaxshort=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SAREXT_StateInit(& _state, startvalue, offsetonreverse, accelerationinitlong, accelerationlong, accelerationmaxlong, accelerationinitshort, accelerationshort, accelerationmaxshort)
    _ta_check_success("TA_SAREXT_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAREXT_State( size_t state , double high , double low ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_SAREXT_State( _state , high , low , &outreal )
    need_mode_data = not _ta_check_success("TA_SAREXT_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAREXT_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None ):
    """ SAREXT_BatchState(high, low)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    length = check_length2(high, low)
    begidx = check_begidx2(length, <double*>(high.data), <double*>(low.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SAREXT_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SAREXT_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAREXT_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_SAREXT_StateFree( & _state )
    _ta_check_success("TA_SAREXT_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAREXT_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "SAREXT"
    _state = <void*> state
    retCode = lib.TA_SAREXT_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_SAREXT_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SAREXT_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SAREXT_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_SAREXT_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SIN( np.ndarray real not None ):
    """ SIN(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_SIN_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SIN( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SIN", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SIN_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SIN_StateInit(& _state)
    _ta_check_success("TA_SIN_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SIN_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_SIN_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_SIN_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SIN_BatchState( size_t state , np.ndarray real not None ):
    """ SIN_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SIN_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SIN_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SIN_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_SIN_StateFree( & _state )
    _ta_check_success("TA_SIN_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SIN_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "SIN"
    _state = <void*> state
    retCode = lib.TA_SIN_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_SIN_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SIN_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SIN_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_SIN_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SINH( np.ndarray real not None ):
    """ SINH(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_SINH_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SINH( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SINH", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SINH_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SINH_StateInit(& _state)
    _ta_check_success("TA_SINH_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SINH_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_SINH_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_SINH_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SINH_BatchState( size_t state , np.ndarray real not None ):
    """ SINH_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SINH_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SINH_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SINH_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_SINH_StateFree( & _state )
    _ta_check_success("TA_SINH_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SINH_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "SINH"
    _state = <void*> state
    retCode = lib.TA_SINH_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_SINH_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SINH_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SINH_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_SINH_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SMA( np.ndarray real not None , int timeperiod=-2**31 ):
    """ SMA(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_SMA_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SMA( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SMA", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SMA_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SMA_StateInit(& _state, timeperiod)
    _ta_check_success("TA_SMA_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SMA_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_SMA_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_SMA_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SMA_BatchState( size_t state , np.ndarray real not None ):
    """ SMA_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SMA_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SMA_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SMA_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_SMA_StateFree( & _state )
    _ta_check_success("TA_SMA_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SMA_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "SMA"
    _state = <void*> state
    retCode = lib.TA_SMA_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_SMA_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SMA_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SMA_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_SMA_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SQRT( np.ndarray real not None ):
    """ SQRT(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_SQRT_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SQRT( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SQRT", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SQRT_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SQRT_StateInit(& _state)
    _ta_check_success("TA_SQRT_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SQRT_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_SQRT_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_SQRT_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SQRT_BatchState( size_t state , np.ndarray real not None ):
    """ SQRT_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SQRT_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SQRT_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SQRT_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_SQRT_StateFree( & _state )
    _ta_check_success("TA_SQRT_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SQRT_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "SQRT"
    _state = <void*> state
    retCode = lib.TA_SQRT_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_SQRT_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SQRT_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SQRT_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_SQRT_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STDDEV( np.ndarray real not None , int timeperiod=-2**31 , double nbdev=-4e37 ):
    """ STDDEV(real[, timeperiod=?, nbdev=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_STDDEV_Lookback( timeperiod , nbdev )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_STDDEV( 0 , endidx , <double *>(real.data)+begidx , timeperiod , nbdev , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_STDDEV", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STDDEV_StateInit( int timeperiod=-2**31 , double nbdev=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_STDDEV_StateInit(& _state, timeperiod, nbdev)
    _ta_check_success("TA_STDDEV_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STDDEV_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_STDDEV_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_STDDEV_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STDDEV_BatchState( size_t state , np.ndarray real not None ):
    """ STDDEV_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_STDDEV_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_STDDEV_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STDDEV_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_STDDEV_StateFree( & _state )
    _ta_check_success("TA_STDDEV_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STDDEV_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "STDDEV"
    _state = <void*> state
    retCode = lib.TA_STDDEV_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_STDDEV_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STDDEV_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_STDDEV_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_STDDEV_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCH( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int fastk_period=-2**31 , int slowk_period=-2**31 , int slowk_matype=0 , int slowd_period=-2**31 , int slowd_matype=0 ):
    """ STOCH(high, low, close[, fastk_period=?, slowk_period=?, slowk_matype=?, slowd_period=?, slowd_matype=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outslowk
        np.ndarray outslowd
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_STOCH_Lookback( fastk_period , slowk_period , slowk_matype , slowd_period , slowd_matype )
    outslowk = make_double_array(length, lookback)
    outslowd = make_double_array(length, lookback)
    retCode = lib.TA_STOCH( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , fastk_period , slowk_period , slowk_matype , slowd_period , slowd_matype , &outbegidx , &outnbelement , <double *>(outslowk.data)+lookback , <double *>(outslowd.data)+lookback )
    _ta_check_success("TA_STOCH", retCode)
    return TALibResult(retCode), outslowk , outslowd 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCH_StateInit( int fastk_period=-2**31 , int slowk_period=-2**31 , int slowk_matype=0 , int slowd_period=-2**31 , int slowd_matype=0 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_STOCH_StateInit(& _state, fastk_period, slowk_period, slowk_matype, slowd_period, slowd_matype)
    _ta_check_success("TA_STOCH_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCH_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outslowk
        double outslowd
    _state = <void*>state
    retCode = lib.TA_STOCH_State( _state , high , low , close , &outslowk , &outslowd )
    need_mode_data = not _ta_check_success("TA_STOCH_State", retCode)
    return TALibResult(retCode), outslowk , outslowd 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCH_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ STOCH_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outslowk
        np.ndarray outslowd
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outslowk = make_double_array(length, lookback)
    outslowd = make_double_array(length, lookback)
    retCode = lib.TA_STOCH_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outslowk.data)+lookback , <double *>(outslowd.data)+lookback )
    _ta_check_success("TA_STOCH_BatchState", retCode)
    return TALibResult(retCode), outslowk , outslowd 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCH_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_STOCH_StateFree( & _state )
    _ta_check_success("TA_STOCH_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCH_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "STOCH"
    _state = <void*> state
    retCode = lib.TA_STOCH_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_STOCH_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCH_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_STOCH_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_STOCH_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHF( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int fastk_period=-2**31 , int fastd_period=-2**31 , int fastd_matype=0 ):
    """ STOCHF(high, low, close[, fastk_period=?, fastd_period=?, fastd_matype=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outfastk
        np.ndarray outfastd
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_STOCHF_Lookback( fastk_period , fastd_period , fastd_matype )
    outfastk = make_double_array(length, lookback)
    outfastd = make_double_array(length, lookback)
    retCode = lib.TA_STOCHF( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , fastk_period , fastd_period , fastd_matype , &outbegidx , &outnbelement , <double *>(outfastk.data)+lookback , <double *>(outfastd.data)+lookback )
    _ta_check_success("TA_STOCHF", retCode)
    return TALibResult(retCode), outfastk , outfastd 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHF_StateInit( int fastk_period=-2**31 , int fastd_period=-2**31 , int fastd_matype=0 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_STOCHF_StateInit(& _state, fastk_period, fastd_period, fastd_matype)
    _ta_check_success("TA_STOCHF_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHF_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outfastk
        double outfastd
    _state = <void*>state
    retCode = lib.TA_STOCHF_State( _state , high , low , close , &outfastk , &outfastd )
    need_mode_data = not _ta_check_success("TA_STOCHF_State", retCode)
    return TALibResult(retCode), outfastk , outfastd 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHF_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ STOCHF_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outfastk
        np.ndarray outfastd
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outfastk = make_double_array(length, lookback)
    outfastd = make_double_array(length, lookback)
    retCode = lib.TA_STOCHF_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outfastk.data)+lookback , <double *>(outfastd.data)+lookback )
    _ta_check_success("TA_STOCHF_BatchState", retCode)
    return TALibResult(retCode), outfastk , outfastd 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHF_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_STOCHF_StateFree( & _state )
    _ta_check_success("TA_STOCHF_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHF_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "STOCHF"
    _state = <void*> state
    retCode = lib.TA_STOCHF_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_STOCHF_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHF_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_STOCHF_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_STOCHF_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHRSI( np.ndarray real not None , int timeperiod=-2**31 , int fastk_period=-2**31 , int fastd_period=-2**31 , int fastd_matype=0 ):
    """ STOCHRSI(real[, timeperiod=?, fastk_period=?, fastd_period=?, fastd_matype=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outfastk
        np.ndarray outfastd
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_STOCHRSI_Lookback( timeperiod , fastk_period , fastd_period , fastd_matype )
    outfastk = make_double_array(length, lookback)
    outfastd = make_double_array(length, lookback)
    retCode = lib.TA_STOCHRSI( 0 , endidx , <double *>(real.data)+begidx , timeperiod , fastk_period , fastd_period , fastd_matype , &outbegidx , &outnbelement , <double *>(outfastk.data)+lookback , <double *>(outfastd.data)+lookback )
    _ta_check_success("TA_STOCHRSI", retCode)
    return TALibResult(retCode), outfastk , outfastd 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHRSI_StateInit( int timeperiod=-2**31 , int fastk_period=-2**31 , int fastd_period=-2**31 , int fastd_matype=0 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_STOCHRSI_StateInit(& _state, timeperiod, fastk_period, fastd_period, fastd_matype)
    _ta_check_success("TA_STOCHRSI_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHRSI_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outfastk
        double outfastd
    _state = <void*>state
    retCode = lib.TA_STOCHRSI_State( _state , real , &outfastk , &outfastd )
    need_mode_data = not _ta_check_success("TA_STOCHRSI_State", retCode)
    return TALibResult(retCode), outfastk , outfastd 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHRSI_BatchState( size_t state , np.ndarray real not None ):
    """ STOCHRSI_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outfastk
        np.ndarray outfastd
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outfastk = make_double_array(length, lookback)
    outfastd = make_double_array(length, lookback)
    retCode = lib.TA_STOCHRSI_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outfastk.data)+lookback , <double *>(outfastd.data)+lookback )
    _ta_check_success("TA_STOCHRSI_BatchState", retCode)
    return TALibResult(retCode), outfastk , outfastd 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHRSI_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_STOCHRSI_StateFree( & _state )
    _ta_check_success("TA_STOCHRSI_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHRSI_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "STOCHRSI"
    _state = <void*> state
    retCode = lib.TA_STOCHRSI_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_STOCHRSI_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def STOCHRSI_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_STOCHRSI_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_STOCHRSI_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUB( np.ndarray real0 not None , np.ndarray real1 not None ):
    """ SUB(real0, real1)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_SUB_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SUB( 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SUB", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUB_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SUB_StateInit(& _state)
    _ta_check_success("TA_SUB_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUB_State( size_t state , double real0 , double real1 ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_SUB_State( _state , real0 , real1 , &outreal )
    need_mode_data = not _ta_check_success("TA_SUB_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUB_BatchState( size_t state , np.ndarray real0 not None , np.ndarray real1 not None ):
    """ SUB_BatchState(real0, real1)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real0 = check_array(real0)
    real1 = check_array(real1)
    length = check_length2(real0, real1)
    begidx = check_begidx2(length, <double*>(real0.data), <double*>(real1.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SUB_BatchState( _state , 0 , endidx , <double *>(real0.data)+begidx , <double *>(real1.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SUB_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUB_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_SUB_StateFree( & _state )
    _ta_check_success("TA_SUB_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUB_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "SUB"
    _state = <void*> state
    retCode = lib.TA_SUB_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_SUB_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUB_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SUB_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_SUB_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUM( np.ndarray real not None , int timeperiod=-2**31 ):
    """ SUM(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_SUM_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SUM( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SUM", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUM_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SUM_StateInit(& _state, timeperiod)
    _ta_check_success("TA_SUM_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUM_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_SUM_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_SUM_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUM_BatchState( size_t state , np.ndarray real not None ):
    """ SUM_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_SUM_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_SUM_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUM_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_SUM_StateFree( & _state )
    _ta_check_success("TA_SUM_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUM_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "SUM"
    _state = <void*> state
    retCode = lib.TA_SUM_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_SUM_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def SUM_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_SUM_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_SUM_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def T3( np.ndarray real not None , int timeperiod=-2**31 , double vfactor=-4e37 ):
    """ T3(real[, timeperiod=?, vfactor=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_T3_Lookback( timeperiod , vfactor )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_T3( 0 , endidx , <double *>(real.data)+begidx , timeperiod , vfactor , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_T3", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def T3_StateInit( int timeperiod=-2**31 , double vfactor=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_T3_StateInit(& _state, timeperiod, vfactor)
    _ta_check_success("TA_T3_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def T3_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_T3_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_T3_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def T3_BatchState( size_t state , np.ndarray real not None ):
    """ T3_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_T3_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_T3_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def T3_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_T3_StateFree( & _state )
    _ta_check_success("TA_T3_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def T3_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "T3"
    _state = <void*> state
    retCode = lib.TA_T3_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_T3_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def T3_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_T3_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_T3_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TAN( np.ndarray real not None ):
    """ TAN(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_TAN_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TAN( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TAN", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TAN_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TAN_StateInit(& _state)
    _ta_check_success("TA_TAN_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TAN_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_TAN_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_TAN_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TAN_BatchState( size_t state , np.ndarray real not None ):
    """ TAN_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TAN_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TAN_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TAN_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_TAN_StateFree( & _state )
    _ta_check_success("TA_TAN_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TAN_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "TAN"
    _state = <void*> state
    retCode = lib.TA_TAN_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_TAN_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TAN_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TAN_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_TAN_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TANH( np.ndarray real not None ):
    """ TANH(real)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_TANH_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TANH( 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TANH", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TANH_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TANH_StateInit(& _state)
    _ta_check_success("TA_TANH_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TANH_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_TANH_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_TANH_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TANH_BatchState( size_t state , np.ndarray real not None ):
    """ TANH_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TANH_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TANH_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TANH_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_TANH_StateFree( & _state )
    _ta_check_success("TA_TANH_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TANH_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "TANH"
    _state = <void*> state
    retCode = lib.TA_TANH_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_TANH_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TANH_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TANH_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_TANH_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TEMA( np.ndarray real not None , int timeperiod=-2**31 ):
    """ TEMA(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_TEMA_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TEMA( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TEMA", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TEMA_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TEMA_StateInit(& _state, timeperiod)
    _ta_check_success("TA_TEMA_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TEMA_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_TEMA_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_TEMA_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TEMA_BatchState( size_t state , np.ndarray real not None ):
    """ TEMA_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TEMA_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TEMA_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TEMA_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_TEMA_StateFree( & _state )
    _ta_check_success("TA_TEMA_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TEMA_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "TEMA"
    _state = <void*> state
    retCode = lib.TA_TEMA_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_TEMA_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TEMA_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TEMA_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_TEMA_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRANGE( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ TRANGE(high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_TRANGE_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TRANGE( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TRANGE", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRANGE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TRANGE_StateInit(& _state)
    _ta_check_success("TA_TRANGE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRANGE_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_TRANGE_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_TRANGE_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRANGE_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ TRANGE_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TRANGE_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TRANGE_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRANGE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_TRANGE_StateFree( & _state )
    _ta_check_success("TA_TRANGE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRANGE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "TRANGE"
    _state = <void*> state
    retCode = lib.TA_TRANGE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_TRANGE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRANGE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TRANGE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_TRANGE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIMA( np.ndarray real not None , int timeperiod=-2**31 ):
    """ TRIMA(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_TRIMA_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TRIMA( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TRIMA", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIMA_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TRIMA_StateInit(& _state, timeperiod)
    _ta_check_success("TA_TRIMA_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIMA_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_TRIMA_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_TRIMA_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIMA_BatchState( size_t state , np.ndarray real not None ):
    """ TRIMA_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TRIMA_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TRIMA_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIMA_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_TRIMA_StateFree( & _state )
    _ta_check_success("TA_TRIMA_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIMA_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "TRIMA"
    _state = <void*> state
    retCode = lib.TA_TRIMA_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_TRIMA_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIMA_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TRIMA_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_TRIMA_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIX( np.ndarray real not None , int timeperiod=-2**31 ):
    """ TRIX(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_TRIX_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TRIX( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TRIX", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIX_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TRIX_StateInit(& _state, timeperiod)
    _ta_check_success("TA_TRIX_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIX_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_TRIX_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_TRIX_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIX_BatchState( size_t state , np.ndarray real not None ):
    """ TRIX_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TRIX_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TRIX_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIX_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_TRIX_StateFree( & _state )
    _ta_check_success("TA_TRIX_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIX_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "TRIX"
    _state = <void*> state
    retCode = lib.TA_TRIX_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_TRIX_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TRIX_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TRIX_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_TRIX_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TSF( np.ndarray real not None , int timeperiod=-2**31 ):
    """ TSF(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_TSF_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TSF( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TSF", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TSF_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TSF_StateInit(& _state, timeperiod)
    _ta_check_success("TA_TSF_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TSF_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_TSF_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_TSF_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TSF_BatchState( size_t state , np.ndarray real not None ):
    """ TSF_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TSF_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TSF_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TSF_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_TSF_StateFree( & _state )
    _ta_check_success("TA_TSF_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TSF_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "TSF"
    _state = <void*> state
    retCode = lib.TA_TSF_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_TSF_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TSF_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TSF_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_TSF_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TYPPRICE( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ TYPPRICE(high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_TYPPRICE_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TYPPRICE( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TYPPRICE", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TYPPRICE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TYPPRICE_StateInit(& _state)
    _ta_check_success("TA_TYPPRICE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TYPPRICE_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_TYPPRICE_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_TYPPRICE_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TYPPRICE_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ TYPPRICE_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_TYPPRICE_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_TYPPRICE_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TYPPRICE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_TYPPRICE_StateFree( & _state )
    _ta_check_success("TA_TYPPRICE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TYPPRICE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "TYPPRICE"
    _state = <void*> state
    retCode = lib.TA_TYPPRICE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_TYPPRICE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def TYPPRICE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_TYPPRICE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_TYPPRICE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ULTOSC( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod1=-2**31 , int timeperiod2=-2**31 , int timeperiod3=-2**31 ):
    """ ULTOSC(high, low, close[, timeperiod1=?, timeperiod2=?, timeperiod3=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_ULTOSC_Lookback( timeperiod1 , timeperiod2 , timeperiod3 )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ULTOSC( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod1 , timeperiod2 , timeperiod3 , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ULTOSC", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ULTOSC_StateInit( int timeperiod1=-2**31 , int timeperiod2=-2**31 , int timeperiod3=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ULTOSC_StateInit(& _state, timeperiod1, timeperiod2, timeperiod3)
    _ta_check_success("TA_ULTOSC_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ULTOSC_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_ULTOSC_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_ULTOSC_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ULTOSC_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ ULTOSC_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_ULTOSC_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_ULTOSC_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ULTOSC_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_ULTOSC_StateFree( & _state )
    _ta_check_success("TA_ULTOSC_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ULTOSC_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "ULTOSC"
    _state = <void*> state
    retCode = lib.TA_ULTOSC_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_ULTOSC_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def ULTOSC_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_ULTOSC_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_ULTOSC_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def VAR( np.ndarray real not None , int timeperiod=-2**31 , double nbdev=-4e37 ):
    """ VAR(real[, timeperiod=?, nbdev=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_VAR_Lookback( timeperiod , nbdev )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_VAR( 0 , endidx , <double *>(real.data)+begidx , timeperiod , nbdev , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_VAR", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def VAR_StateInit( int timeperiod=-2**31 , double nbdev=-4e37 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_VAR_StateInit(& _state, timeperiod, nbdev)
    _ta_check_success("TA_VAR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def VAR_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_VAR_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_VAR_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def VAR_BatchState( size_t state , np.ndarray real not None ):
    """ VAR_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_VAR_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_VAR_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def VAR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_VAR_StateFree( & _state )
    _ta_check_success("TA_VAR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def VAR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "VAR"
    _state = <void*> state
    retCode = lib.TA_VAR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_VAR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def VAR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_VAR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_VAR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WCLPRICE( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ WCLPRICE(high, low, close)"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_WCLPRICE_Lookback( )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_WCLPRICE( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_WCLPRICE", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WCLPRICE_StateInit( ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_WCLPRICE_StateInit(& _state)
    _ta_check_success("TA_WCLPRICE_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WCLPRICE_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_WCLPRICE_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_WCLPRICE_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WCLPRICE_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ WCLPRICE_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_WCLPRICE_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_WCLPRICE_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WCLPRICE_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_WCLPRICE_StateFree( & _state )
    _ta_check_success("TA_WCLPRICE_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WCLPRICE_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "WCLPRICE"
    _state = <void*> state
    retCode = lib.TA_WCLPRICE_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_WCLPRICE_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WCLPRICE_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_WCLPRICE_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_WCLPRICE_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WILLR( np.ndarray high not None , np.ndarray low not None , np.ndarray close not None , int timeperiod=-2**31 ):
    """ WILLR(high, low, close[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_WILLR_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_WILLR( 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_WILLR", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WILLR_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_WILLR_StateInit(& _state, timeperiod)
    _ta_check_success("TA_WILLR_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WILLR_State( size_t state , double high , double low , double close ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_WILLR_State( _state , high , low , close , &outreal )
    need_mode_data = not _ta_check_success("TA_WILLR_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WILLR_BatchState( size_t state , np.ndarray high not None , np.ndarray low not None , np.ndarray close not None ):
    """ WILLR_BatchState(high, low, close)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    high = check_array(high)
    low = check_array(low)
    close = check_array(close)
    length = check_length3(high, low, close)
    begidx = check_begidx3(length, <double*>(high.data), <double*>(low.data), <double*>(close.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_WILLR_BatchState( _state , 0 , endidx , <double *>(high.data)+begidx , <double *>(low.data)+begidx , <double *>(close.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_WILLR_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WILLR_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_WILLR_StateFree( & _state )
    _ta_check_success("TA_WILLR_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WILLR_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "WILLR"
    _state = <void*> state
    retCode = lib.TA_WILLR_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_WILLR_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WILLR_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_WILLR_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_WILLR_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WMA( np.ndarray real not None , int timeperiod=-2**31 ):
    """ WMA(real[, timeperiod=?])"""
    cdef:
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx + lib.TA_WMA_Lookback( timeperiod )
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_WMA( 0 , endidx , <double *>(real.data)+begidx , timeperiod , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_WMA", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WMA_StateInit( int timeperiod=-2**31 ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_WMA_StateInit(& _state, timeperiod)
    _ta_check_success("TA_WMA_StateInit", retCode)
    return TALibResult(retCode), <size_t>_state


@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WMA_State( size_t state , double real ):
    cdef:
        void * _state;
        TA_RetCode retCode
        double outreal
    _state = <void*>state
    retCode = lib.TA_WMA_State( _state , real , &outreal )
    need_mode_data = not _ta_check_success("TA_WMA_State", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WMA_BatchState( size_t state , np.ndarray real not None ):
    """ WMA_BatchState(real)"""
    cdef:
        void * _state;
        np.npy_intp length
        int begidx, endidx, lookback
        TA_RetCode retCode
        int outbegidx
        int outnbelement
        np.ndarray outreal
    _state = <void*> state
    real = check_array(real)
    length = real.shape[0]
    begidx = check_begidx1(length, <double*>(real.data))
    endidx = <int>length - begidx - 1
    lookback = begidx
    outreal = make_double_array(length, lookback)
    retCode = lib.TA_WMA_BatchState( _state , 0 , endidx , <double *>(real.data)+begidx , &outbegidx , &outnbelement , <double *>(outreal.data)+lookback )
    _ta_check_success("TA_WMA_BatchState", retCode)
    return TALibResult(retCode), outreal 

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WMA_StateFree( size_t state ):
    cdef:
        void * _state;
        TA_RetCode retCode
    _state = <void*>state
    retCode = lib.TA_WMA_StateFree( & _state )
    _ta_check_success("TA_WMA_StateFree", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WMA_StateSave( size_t state , int hFile ):
    cdef:
        void * _state;
        TA_RetCode retCode
        const char* name = "WMA"
    _state = <void*> state
    retCode = lib.TA_WMA_StateSave( _state, <FILE *>hFile )
    _ta_check_success("TA_WMA_StateSave", retCode)
    return TALibResult(retCode)

@wraparound(False)  # turn off relative indexing from end of lists
@boundscheck(False) # turn off bounds-checking for entire function
def WMA_StateLoad( int hFile ):
    cdef:
        void * _state
        TA_RetCode retCode
    retCode = lib.TA_WMA_StateLoad(&_state, <FILE *>hFile)
    _ta_check_success("TA_WMA_StateLoad", retCode)
    return TALibResult(retCode), <size_t>_state


__TA_FUNCTION_NAMES__ = ["ACCBANDS","ACOS","AD","ADD","ADOSC","ADX","ADXR","APO","AROON","AROONOSC","ASIN","ATAN","ATR","AVGPRICE","AVGDEV","BBANDS","BETA","BOP","CCI","CDL2CROWS","CDL3BLACKCROWS","CDL3INSIDE","CDL3LINESTRIKE","CDL3OUTSIDE","CDL3STARSINSOUTH","CDL3WHITESOLDIERS","CDLABANDONEDBABY","CDLADVANCEBLOCK","CDLBELTHOLD","CDLBREAKAWAY","CDLCLOSINGMARUBOZU","CDLCONCEALBABYSWALL","CDLCOUNTERATTACK","CDLDARKCLOUDCOVER","CDLDOJI","CDLDOJISTAR","CDLDRAGONFLYDOJI","CDLENGULFING","CDLEVENINGDOJISTAR","CDLEVENINGSTAR","CDLGAPSIDESIDEWHITE","CDLGRAVESTONEDOJI","CDLHAMMER","CDLHANGINGMAN","CDLHARAMI","CDLHARAMICROSS","CDLHIGHWAVE","CDLHIKKAKE","CDLHIKKAKEMOD","CDLHOMINGPIGEON","CDLIDENTICAL3CROWS","CDLINNECK","CDLINVERTEDHAMMER","CDLKICKING","CDLKICKINGBYLENGTH","CDLLADDERBOTTOM","CDLLONGLEGGEDDOJI","CDLLONGLINE","CDLMARUBOZU","CDLMATCHINGLOW","CDLMATHOLD","CDLMORNINGDOJISTAR","CDLMORNINGSTAR","CDLONNECK","CDLPIERCING","CDLRICKSHAWMAN","CDLRISEFALL3METHODS","CDLSEPARATINGLINES","CDLSHOOTINGSTAR","CDLSHORTLINE","CDLSPINNINGTOP","CDLSTALLEDPATTERN","CDLSTICKSANDWICH","CDLTAKURI","CDLTASUKIGAP","CDLTHRUSTING","CDLTRISTAR","CDLUNIQUE3RIVER","CDLUPSIDEGAP2CROWS","CDLXSIDEGAP3METHODS","CEIL","CMO","CORREL","COS","COSH","DEMA","DIV","DX","EMA","EXP","FLOOR","HT_DCPERIOD","HT_DCPHASE","HT_PHASOR","HT_SINE","HT_TRENDLINE","HT_TRENDMODE","IMI","KAMA","LINEARREG","LINEARREG_ANGLE","LINEARREG_INTERCEPT","LINEARREG_SLOPE","LN","LOG10","MA","MACD","MACDEXT","MACDFIX","MAMA","MAVP","MAX","MAXINDEX","MEDPRICE","MFI","MIDPOINT","MIDPRICE","MIN","MININDEX","MINMAX","MINMAXINDEX","MINUS_DI","MINUS_DM","MOM","MULT","NATR","NVI","OBV","PLUS_DI","PLUS_DM","PPO","PVI","PVT","ROC","ROCP","ROCR","ROCR100","RSI","SAR","SAREXT","SIN","SINH","SMA","SQRT","STDDEV","STOCH","STOCHF","STOCHRSI","SUB","SUM","T3","TAN","TANH","TEMA","TRANGE","TRIMA","TRIX","TSF","TYPPRICE","ULTOSC","VAR","WCLPRICE","WILLR","WMA"]
