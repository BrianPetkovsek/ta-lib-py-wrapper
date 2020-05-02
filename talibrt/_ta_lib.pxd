
cdef extern from "ta-lib-rt/ta_defs.h":

    ctypedef int TA_RetCode
    TA_RetCode TA_SUCCESS = 0
    TA_RetCode TA_LIB_NOT_INITIALIZE = 1
    TA_RetCode TA_BAD_PARAM = 2
    TA_RetCode TA_ALLOC_ERR = 3
    TA_RetCode TA_GROUP_NOT_FOUND = 4
    TA_RetCode TA_FUNC_NOT_FOUND = 5
    TA_RetCode TA_INVALID_HANDLE = 6
    TA_RetCode TA_INVALID_PARAM_HOLDER = 7
    TA_RetCode TA_INVALID_PARAM_HOLDER_TYPE = 8
    TA_RetCode TA_INVALID_PARAM_FUNCTION = 9
    TA_RetCode TA_INPUT_NOT_ALL_INITIALIZE = 10
    TA_RetCode TA_OUTPUT_NOT_ALL_INITIALIZE = 11
    TA_RetCode TA_OUT_OF_RANGE_START_INDEX = 12
    TA_RetCode TA_OUT_OF_RANGE_END_INDEX = 13
    TA_RetCode TA_INVALID_LIST_TYPE = 14
    TA_RetCode TA_BAD_OBJECT = 15
    TA_RetCode TA_NOT_SUPPORTED = 16
    TA_RetCode TA_NEED_MORE_DATA = 17
    TA_RetCode TA_IO_FAILED = 18
    TA_RetCode TA_INTERNAL_ERROR = 5000
    TA_RetCode TA_UNKNOWN_ERR = 0xffff

    ctypedef int TA_Compatibility
    TA_Compatibility TA_COMPATIBILITY_DEFAULT = 0
    TA_Compatibility TA_COMPATIBILITY_METASTOCK = 1

    ctypedef int TA_MAType
    TA_MAType TA_MAType_SMA = 0
    TA_MAType TA_MAType_EMA = 1
    TA_MAType TA_MAType_WMA = 2
    TA_MAType TA_MAType_DEMA = 3
    TA_MAType TA_MAType_TEMA = 4
    TA_MAType TA_MAType_TRIMA = 5
    TA_MAType TA_MAType_KAMA = 6
    TA_MAType TA_MAType_MAMA = 7
    TA_MAType TA_MAType_T3 = 8

    ctypedef int TA_FuncUnstId
    TA_FuncUnstId TA_FUNC_UNST_ADX = 0
    TA_FuncUnstId TA_FUNC_UNST_ADXR = 1
    TA_FuncUnstId TA_FUNC_UNST_ATR = 2
    TA_FuncUnstId TA_FUNC_UNST_CMO = 3
    TA_FuncUnstId TA_FUNC_UNST_DX = 4
    TA_FuncUnstId TA_FUNC_UNST_EMA = 5
    TA_FuncUnstId TA_FUNC_UNST_HT_DCPERIOD = 6
    TA_FuncUnstId TA_FUNC_UNST_HT_DCPHASE = 7
    TA_FuncUnstId TA_FUNC_UNST_HD_PHASOR = 8
    TA_FuncUnstId TA_FUNC_UNST_HT_SINE = 9
    TA_FuncUnstId TA_FUNC_UNST_HT_TRENDLINE = 10
    TA_FuncUnstId TA_FUNC_UNST_HT_TRENDMODE = 11
    TA_FuncUnstId TA_FUNC_UNST_IMI = 12
    TA_FuncUnstId TA_FUNC_UNST_KAMA = 13
    TA_FuncUnstId TA_FUNC_UNST_MAMA = 14
    TA_FuncUnstId TA_FUNC_UNST_MFI = 15
    TA_FuncUnstId TA_FUNC_UNST_MINUS_DI = 16
    TA_FuncUnstId TA_FUNC_UNST_MINUS_DM = 17
    TA_FuncUnstId TA_FUNC_UNST_NATR = 18
    TA_FuncUnstId TA_FUNC_UNST_PLUS_DI = 19
    TA_FuncUnstId TA_FUNC_UNST_PLUS_DM = 20
    TA_FuncUnstId TA_FUNC_UNST_RSI = 21
    TA_FuncUnstId TA_FUNC_UNST_STOCHRSI = 22
    TA_FuncUnstId TA_FUNC_UNST_T3 = 23
    TA_FuncUnstId TA_FUNC_UNST_ALL = 24
    TA_FuncUnstId TA_FUNC_UNST_NONE = -1

    ctypedef int TA_RangeType
    TA_RangeType TA_RangeType_RealBody = 0
    TA_RangeType TA_RangeType_HighLow = 1
    TA_RangeType TA_RangeType_Shadows = 2

    ctypedef int TA_CandleSettingType
    TA_CandleSettingType TA_BodyLong = 0
    TA_CandleSettingType TA_BodyVeryLong = 1
    TA_CandleSettingType TA_BodyShort = 2
    TA_CandleSettingType TA_BodyDoji = 3
    TA_CandleSettingType TA_ShadowLong = 4
    TA_CandleSettingType TA_ShadowVeryLong = 5
    TA_CandleSettingType TA_ShadowShort = 6
    TA_CandleSettingType TA_ShadowVeryShort = 7
    TA_CandleSettingType TA_Near = 8
    TA_CandleSettingType TA_Far = 9
    TA_CandleSettingType TA_Equal = 10
    TA_CandleSettingType TA_AllCandleSettings = 11

cdef extern from "ta-lib-rt/ta_common.h":
    char *TA_GetVersionString()
    char *TA_GetVersionMajor()
    char *TA_GetVersionMinor()
    char *TA_GetVersionBuild()
    char *TA_GetVersionDate()
    char *TA_GetVersionTime()

    ctypedef double TA_Real
    ctypedef int TA_Integer

    ctypedef struct TA_StringTable:
        unsigned int size
        char **string
        void *hiddenData

    ctypedef struct TA_RetCodeInfo:
        char* enumStr
        char* infoStr

    void TA_SetRetCodeInfo(TA_RetCode theRetCode, TA_RetCodeInfo *retCodeInfo)

    TA_RetCode TA_Initialize()
    TA_RetCode TA_Shutdown()

cdef extern from "ta-lib-rt/ta_abstract.h":

    TA_RetCode TA_GroupTableAlloc(TA_StringTable **table)
    TA_RetCode TA_GroupTableFree(TA_StringTable *table)

    TA_RetCode TA_FuncTableAlloc(char *group, TA_StringTable **table)
    TA_RetCode TA_FuncTableFree(TA_StringTable *table)

    ctypedef unsigned int TA_FuncHandle
    TA_RetCode TA_GetFuncHandle(char *name, TA_FuncHandle **handle)

    ctypedef int TA_FuncFlags
    ctypedef struct TA_FuncInfo:
        char *name
        char *group
        char *hint
        char *camelCaseName
        TA_FuncFlags flags
        unsigned int nbInput
        unsigned int nbOptInput
        unsigned int nbOutput
        unsigned int nbStructParams
        TA_FuncHandle *handle

    TA_RetCode TA_GetFuncInfo(TA_FuncHandle *handle, TA_FuncInfo **funcInfo)

    TA_RetCode TA_GetInitNewStateFuncPtr(const TA_FuncInfo *funcInfo, TA_FuncHandle* handle );
    TA_RetCode TA_GetCallFuncStateFuncPtr(const TA_FuncInfo *funcInfo, TA_FuncHandle* handle );
    TA_RetCode TA_GetFreeStateFuncPtr(const TA_FuncInfo *funcInfo, TA_FuncHandle *handle );
    TA_RetCode TA_GetSaveStateFuncPtr(const TA_FuncInfo *funcInfo, TA_FuncHandle *handle );
    TA_RetCode TA_GetLoadStateFuncPtr(const TA_FuncInfo *funcInfo, TA_FuncHandle *handle );

    ctypedef int TA_InputParameterType
    TA_InputParameterType TA_Input_Price = 0
    TA_InputParameterType TA_Input_Real = 1
    TA_InputParameterType TA_Input_Integer = 2
    TA_InputParameterType TA_Input_Pointer = 3

    ctypedef int TA_OptInputParameterType
    TA_OptInputParameterType TA_OptInput_RealRange = 0
    TA_OptInputParameterType TA_OptInput_RealList = 1
    TA_OptInputParameterType TA_OptInput_IntegerRange = 2
    TA_OptInputParameterType TA_OptInput_IntegerList = 3

    ctypedef int TA_OutputParameterType
    TA_OutputParameterType TA_Output_Real = 0
    TA_OutputParameterType TA_Output_Integer = 1

    ctypedef int TA_InputFlags
    ctypedef int TA_OptInputFlags
    ctypedef int TA_OutputFlags

    ctypedef struct TA_InputParameterInfo:
        TA_InputParameterType type
        char *paramName
        TA_InputFlags flags

    ctypedef struct TA_OptInputParameterInfo:
        TA_OptInputParameterType type
        char *paramName
        TA_OptInputFlags flags
        char *displayName
        void *dataSet
        TA_Real defaultValue
        char *hint
        char *helpFile

    ctypedef struct TA_OutputParameterInfo:
        TA_OutputParameterType type
        char *paramName
        TA_OutputFlags flags
        
    ctypedef struct TA_StructParameterInfo:
        TA_OutputParameterType type
        char *paramName
        TA_InputFlags flags

    TA_RetCode TA_GetInputParameterInfo(TA_FuncHandle *handle, unsigned int paramIndex, TA_InputParameterInfo **info)
    TA_RetCode TA_GetOptInputParameterInfo(TA_FuncHandle *handle, unsigned int paramIndex, TA_OptInputParameterInfo **info)
    TA_RetCode TA_GetOutputParameterInfo(TA_FuncHandle *handle, unsigned int paramIndex, TA_OutputParameterInfo **info)
    TA_RetCode TA_GetStructParameterInfo(TA_FuncHandle *handle, unsigned int paramIndex, TA_InputParameterInfo **info)

    ctypedef struct TA_ParamHolder:
        void *hiddenData

    TA_RetCode TA_ParamHolderAlloc(TA_FuncHandle *handle, TA_ParamHolder **allocatedParams) # get_lookback()
    TA_RetCode TA_ParamHolderFree(TA_ParamHolder *params)

    TA_RetCode TA_SetInputParamRealPtr(TA_ParamHolder *params, unsigned int paramIndex, const TA_Real *value)
    TA_RetCode TA_SetInputParamPricePtr(TA_ParamHolder *params, unsigned int paramIndex, const TA_Real *open, const TA_Real *high, const TA_Real *low, const TA_Real *close, const TA_Real *volume, const TA_Real *openInterest)    
    TA_RetCode TA_SetOptInputParamInteger(TA_ParamHolder *params, unsigned int paramIndex, TA_Integer optInValue)
    TA_RetCode TA_SetOptInputParamReal(TA_ParamHolder *params, unsigned int paramIndex, TA_Real optInValue)

    TA_RetCode TA_GetLookback(TA_ParamHolder *params, TA_Integer *lookback)
    TA_RetCode TA_CallFunc(TA_ParamHolder *params, TA_Integer startIdx, TA_Integer endIdx, TA_Integer *outBegIdx, TA_Integer *outNbElement)
    TA_RetCode TA_InitNewState( TA_ParamHolder *params );
    TA_RetCode TA_CallFuncState( TA_ParamHolder *params );
    TA_RetCode TA_FreeState( TA_ParamHolder *params );
    TA_RetCode TA_SaveState( TA_ParamHolder *params, FILE *_file );
    TA_RetCode TA_LoadState( TA_ParamHolder *params, FILE *_file );

    char* TA_FunctionDescriptionXML()

cdef extern from "<stdio.h>" nogil:

    ctypedef struct FILE
    
cdef extern from "ta-lib-rt/ta_func.h":
    
    int TA_ACCBANDS_Lookback(int optInTimePeriod)
    TA_RetCode TA_ACCBANDS_StateFree( void** _state )
    TA_RetCode TA_ACCBANDS_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_ACCBANDS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ACCBANDS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ACCBANDS_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outRealUpperBand, double *outRealMiddleBand, double *outRealLowerBand)
    TA_RetCode TA_ACCBANDS_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outRealUpperBand[], double outRealMiddleBand[], double outRealLowerBand[])
    TA_RetCode TA_ACCBANDS(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outRealUpperBand[], double outRealMiddleBand[], double outRealLowerBand[])

    int TA_ACOS_Lookback()
    TA_RetCode TA_ACOS_StateFree( void** _state )
    TA_RetCode TA_ACOS_StateInit( void** _state )
    TA_RetCode TA_ACOS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ACOS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ACOS_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_ACOS_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ACOS(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_ADD_Lookback()
    TA_RetCode TA_ADD_StateFree( void** _state )
    TA_RetCode TA_ADD_StateInit( void** _state )
    TA_RetCode TA_ADD_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ADD_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ADD_State( void *_state, const double inReal0, const double inReal1, double *outReal)
    TA_RetCode TA_ADD_BatchState( void *_state, int startIdx, int endIdx, const double inReal0[], const double inReal1[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ADD(int startIdx, int endIdx, const double inReal0[], const double inReal1[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_ADOSC_Lookback(int optInFastPeriod, int optInSlowPeriod)
    TA_RetCode TA_ADOSC_StateFree( void** _state )
    TA_RetCode TA_ADOSC_StateInit( void** _state, int optInFastPeriod, int optInSlowPeriod )
    TA_RetCode TA_ADOSC_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ADOSC_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ADOSC_State( void *_state, const double inHigh, const double inLow, const double inClose, const double inVolume, double *outReal)
    TA_RetCode TA_ADOSC_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ADOSC(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], const double inVolume[], int optInFastPeriod, int optInSlowPeriod, int *outBegIdx, int *outNBElement, double outReal[])
    
    int TA_AD_Lookback()
    TA_RetCode TA_AD_StateFree( void** _state )
    TA_RetCode TA_AD_StateInit( void** _state )
    TA_RetCode TA_AD_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_AD_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_AD_State( void *_state, const double inHigh, const double inLow, const double inClose, const double inVolume, double *outReal)
    TA_RetCode TA_AD_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_AD(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_ADXR_Lookback(int optInTimePeriod)
    TA_RetCode TA_ADXR_StateFree( void** _state )
    TA_RetCode TA_ADXR_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_ADXR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ADXR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ADXR_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_ADXR_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ADXR(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])
    
    int TA_ADX_Lookback(int optInTimePeriod)    
    TA_RetCode TA_ADX_StateFree( void** _state )
    TA_RetCode TA_ADX_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_ADX_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ADX_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ADX_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_ADX_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ADX(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_APO_Lookback(int optInFastPeriod, int optInSlowPeriod, TA_MAType optInMAType)
    TA_RetCode TA_APO_StateFree( void** _state )
    TA_RetCode TA_APO_StateInit( void** _state, int optInFastPeriod, int optInSlowPeriod, TA_MAType optInMAType )
    TA_RetCode TA_APO_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_APO_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_APO_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_APO_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_APO(int startIdx, int endIdx, const double inReal[], int optInFastPeriod, int optInSlowPeriod, TA_MAType optInMAType, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_AROONOSC_Lookback(int optInTimePeriod)
    TA_RetCode TA_AROONOSC_StateFree( void** _state )
    TA_RetCode TA_AROONOSC_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_AROONOSC_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_AROONOSC_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_AROONOSC_State( void *_state, const double inHigh, const double inLow, double *outReal)
    TA_RetCode TA_AROONOSC_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_AROONOSC(int startIdx, int endIdx, const double inHigh[], const double inLow[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])
    
    int TA_AROON_Lookback(int optInTimePeriod)
    TA_RetCode TA_AROON_StateFree( void** _state )
    TA_RetCode TA_AROON_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_AROON_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_AROON_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_AROON_State( void *_state, const double inHigh, const double inLow, double *outAroonDown, double *outAroonUp)
    TA_RetCode TA_AROON_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], int *outBegIdx, int *outNBElement, double outAroonDown[], double outAroonUp[])
    TA_RetCode TA_AROON(int startIdx, int endIdx, const double inHigh[], const double inLow[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outAroonDown[], double outAroonUp[])

    int TA_ASIN_Lookback()
    TA_RetCode TA_ASIN_StateFree( void** _state )
    TA_RetCode TA_ASIN_StateInit( void** _state )
    TA_RetCode TA_ASIN_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ASIN_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ASIN_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_ASIN_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ASIN(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_ATAN_Lookback()
    TA_RetCode TA_ATAN_StateFree( void** _state )
    TA_RetCode TA_ATAN_StateInit( void** _state )
    TA_RetCode TA_ATAN_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ATAN_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ATAN_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_ATAN_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ATAN(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_ATR_Lookback(int optInTimePeriod)
    TA_RetCode TA_ATR_StateFree( void** _state )
    TA_RetCode TA_ATR_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_ATR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ATR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ATR_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_ATR_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ATR(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_AVGDEV_Lookback(int optInTimePeriod)
    TA_RetCode TA_AVGDEV_StateFree( void** _state )
    TA_RetCode TA_AVGDEV_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_AVGDEV_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_AVGDEV_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_AVGDEV_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_AVGDEV_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_AVGDEV(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_AVGPRICE_Lookback()
    TA_RetCode TA_AVGPRICE_StateFree( void** _state )
    TA_RetCode TA_AVGPRICE_StateInit( void** _state )
    TA_RetCode TA_AVGPRICE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_AVGPRICE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_AVGPRICE_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_AVGPRICE_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_AVGPRICE(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_BBANDS_Lookback(int optInTimePeriod, double optInNbDevUp, double optInNbDevDn, TA_MAType optInMAType)
    TA_RetCode TA_BBANDS_StateFree( void** _state )
    TA_RetCode TA_BBANDS_StateInit( void** _state, int optInTimePeriod, double optInNbDevUp, double optInNbDevDn, TA_MAType optInMAType )
    TA_RetCode TA_BBANDS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_BBANDS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_BBANDS_State( void *_state, const double inReal, double *outRealUpperBand, double *outRealMiddleBand, double *outRealLowerBand)
    TA_RetCode TA_BBANDS_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outRealUpperBand[], double outRealMiddleBand[], double outRealLowerBand[])
    TA_RetCode TA_BBANDS(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, double optInNbDevUp, double optInNbDevDn, TA_MAType optInMAType, int *outBegIdx, int *outNBElement, double outRealUpperBand[], double outRealMiddleBand[], double outRealLowerBand[])

    int TA_BETA_Lookback(int optInTimePeriod)
    TA_RetCode TA_BETA_StateFree( void** _state )
    TA_RetCode TA_BETA_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_BETA_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_BETA_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_BETA_State( void *_state, const double inReal0, const double inReal1, double *outReal)
    TA_RetCode TA_BETA_BatchState( void *_state, int startIdx, int endIdx, const double inReal0[], const double inReal1[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_BETA(int startIdx, int endIdx, const double inReal0[], const double inReal1[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_BOP_Lookback()
    TA_RetCode TA_BOP_StateFree( void** _state )
    TA_RetCode TA_BOP_StateInit( void** _state )
    TA_RetCode TA_BOP_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_BOP_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_BOP_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_BOP_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_BOP(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_CCI_Lookback(int optInTimePeriod)
    TA_RetCode TA_CCI_StateFree( void** _state )
    TA_RetCode TA_CCI_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_CCI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CCI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CCI_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_CCI_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_CCI(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_CDL2CROWS_Lookback()
    TA_RetCode TA_CDL2CROWS_StateFree( void** _state )
    TA_RetCode TA_CDL2CROWS_StateInit( void** _state )
    TA_RetCode TA_CDL2CROWS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDL2CROWS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDL2CROWS_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDL2CROWS_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDL2CROWS(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDL3BLACKCROWS_Lookback()
    TA_RetCode TA_CDL3BLACKCROWS_StateFree( void** _state )
    TA_RetCode TA_CDL3BLACKCROWS_StateInit( void** _state )
    TA_RetCode TA_CDL3BLACKCROWS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDL3BLACKCROWS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDL3BLACKCROWS_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDL3BLACKCROWS_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDL3BLACKCROWS(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDL3INSIDE_Lookback()
    TA_RetCode TA_CDL3INSIDE_StateFree( void** _state )
    TA_RetCode TA_CDL3INSIDE_StateInit( void** _state )
    TA_RetCode TA_CDL3INSIDE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDL3INSIDE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDL3INSIDE_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDL3INSIDE_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDL3INSIDE(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDL3LINESTRIKE_Lookback()
    TA_RetCode TA_CDL3LINESTRIKE_StateFree( void** _state )
    TA_RetCode TA_CDL3LINESTRIKE_StateInit( void** _state )
    TA_RetCode TA_CDL3LINESTRIKE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDL3LINESTRIKE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDL3LINESTRIKE_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDL3LINESTRIKE_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDL3LINESTRIKE(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDL3OUTSIDE_Lookback()
    TA_RetCode TA_CDL3OUTSIDE_StateFree( void** _state )
    TA_RetCode TA_CDL3OUTSIDE_StateInit( void** _state )
    TA_RetCode TA_CDL3OUTSIDE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDL3OUTSIDE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDL3OUTSIDE_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDL3OUTSIDE_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDL3OUTSIDE(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDL3STARSINSOUTH_Lookback()
    TA_RetCode TA_CDL3STARSINSOUTH_StateFree( void** _state )
    TA_RetCode TA_CDL3STARSINSOUTH_StateInit( void** _state )
    TA_RetCode TA_CDL3STARSINSOUTH_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDL3STARSINSOUTH_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDL3STARSINSOUTH_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDL3STARSINSOUTH_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDL3STARSINSOUTH(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDL3WHITESOLDIERS_Lookback()
    TA_RetCode TA_CDL3WHITESOLDIERS_StateFree( void** _state )
    TA_RetCode TA_CDL3WHITESOLDIERS_StateInit( void** _state )
    TA_RetCode TA_CDL3WHITESOLDIERS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDL3WHITESOLDIERS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDL3WHITESOLDIERS_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDL3WHITESOLDIERS_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDL3WHITESOLDIERS(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLABANDONEDBABY_Lookback(double optInPenetration)
    TA_RetCode TA_CDLABANDONEDBABY_StateFree( void** _state )
    TA_RetCode TA_CDLABANDONEDBABY_StateInit( void** _state, double optInPenetration )
    TA_RetCode TA_CDLABANDONEDBABY_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLABANDONEDBABY_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLABANDONEDBABY_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLABANDONEDBABY_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLABANDONEDBABY(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], double optInPenetration, int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLADVANCEBLOCK_Lookback()
    TA_RetCode TA_CDLADVANCEBLOCK_StateFree( void** _state )
    TA_RetCode TA_CDLADVANCEBLOCK_StateInit( void** _state )
    TA_RetCode TA_CDLADVANCEBLOCK_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLADVANCEBLOCK_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLADVANCEBLOCK_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLADVANCEBLOCK_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLADVANCEBLOCK(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLBELTHOLD_Lookback()
    TA_RetCode TA_CDLBELTHOLD_StateFree( void** _state )
    TA_RetCode TA_CDLBELTHOLD_StateInit( void** _state )
    TA_RetCode TA_CDLBELTHOLD_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLBELTHOLD_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLBELTHOLD_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLBELTHOLD_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLBELTHOLD(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLBREAKAWAY_Lookback()
    TA_RetCode TA_CDLBREAKAWAY_StateFree( void** _state )
    TA_RetCode TA_CDLBREAKAWAY_StateInit( void** _state )
    TA_RetCode TA_CDLBREAKAWAY_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLBREAKAWAY_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLBREAKAWAY_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLBREAKAWAY_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLBREAKAWAY(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLCLOSINGMARUBOZU_Lookback()
    TA_RetCode TA_CDLCLOSINGMARUBOZU_StateFree( void** _state )
    TA_RetCode TA_CDLCLOSINGMARUBOZU_StateInit( void** _state )
    TA_RetCode TA_CDLCLOSINGMARUBOZU_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLCLOSINGMARUBOZU_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLCLOSINGMARUBOZU_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLCLOSINGMARUBOZU_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLCLOSINGMARUBOZU(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLCONCEALBABYSWALL_Lookback()
    TA_RetCode TA_CDLCONCEALBABYSWALL_StateFree( void** _state )
    TA_RetCode TA_CDLCONCEALBABYSWALL_StateInit( void** _state )
    TA_RetCode TA_CDLCONCEALBABYSWALL_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLCONCEALBABYSWALL_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLCONCEALBABYSWALL_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLCONCEALBABYSWALL_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLCONCEALBABYSWALL(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLCOUNTERATTACK_Lookback()
    TA_RetCode TA_CDLCOUNTERATTACK_StateFree( void** _state )
    TA_RetCode TA_CDLCOUNTERATTACK_StateInit( void** _state )
    TA_RetCode TA_CDLCOUNTERATTACK_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLCOUNTERATTACK_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLCOUNTERATTACK_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLCOUNTERATTACK_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLCOUNTERATTACK(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLDARKCLOUDCOVER_Lookback(double optInPenetration)
    TA_RetCode TA_CDLDARKCLOUDCOVER_StateFree( void** _state )
    TA_RetCode TA_CDLDARKCLOUDCOVER_StateInit( void** _state, double optInPenetration )
    TA_RetCode TA_CDLDARKCLOUDCOVER_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLDARKCLOUDCOVER_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLDARKCLOUDCOVER_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLDARKCLOUDCOVER_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLDARKCLOUDCOVER(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], double optInPenetration, int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLDOJISTAR_Lookback()
    TA_RetCode TA_CDLDOJISTAR_StateFree( void** _state )
    TA_RetCode TA_CDLDOJISTAR_StateInit( void** _state )
    TA_RetCode TA_CDLDOJISTAR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLDOJISTAR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLDOJISTAR_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLDOJISTAR_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLDOJISTAR(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    
    int TA_CDLDOJI_Lookback()
    TA_RetCode TA_CDLDOJI_StateFree( void** _state )
    TA_RetCode TA_CDLDOJI_StateInit( void** _state )
    TA_RetCode TA_CDLDOJI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLDOJI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLDOJI_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLDOJI_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLDOJI(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLDRAGONFLYDOJI_Lookback()
    TA_RetCode TA_CDLDRAGONFLYDOJI_StateFree( void** _state )
    TA_RetCode TA_CDLDRAGONFLYDOJI_StateInit( void** _state )
    TA_RetCode TA_CDLDRAGONFLYDOJI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLDRAGONFLYDOJI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLDRAGONFLYDOJI_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLDRAGONFLYDOJI_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLDRAGONFLYDOJI(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLENGULFING_Lookback()
    TA_RetCode TA_CDLENGULFING_StateFree( void** _state )
    TA_RetCode TA_CDLENGULFING_StateInit( void** _state )
    TA_RetCode TA_CDLENGULFING_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLENGULFING_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLENGULFING_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLENGULFING_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLENGULFING(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLEVENINGDOJISTAR_Lookback(double optInPenetration)
    TA_RetCode TA_CDLEVENINGDOJISTAR_StateFree( void** _state )
    TA_RetCode TA_CDLEVENINGDOJISTAR_StateInit( void** _state, double optInPenetration )
    TA_RetCode TA_CDLEVENINGDOJISTAR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLEVENINGDOJISTAR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLEVENINGDOJISTAR_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLEVENINGDOJISTAR_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLEVENINGDOJISTAR(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], double optInPenetration, int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLEVENINGSTAR_Lookback(double optInPenetration)
    TA_RetCode TA_CDLEVENINGSTAR_StateFree( void** _state )
    TA_RetCode TA_CDLEVENINGSTAR_StateInit( void** _state, double optInPenetration )
    TA_RetCode TA_CDLEVENINGSTAR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLEVENINGSTAR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLEVENINGSTAR_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLEVENINGSTAR_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLEVENINGSTAR(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], double optInPenetration, int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLGAPSIDESIDEWHITE_Lookback()
    TA_RetCode TA_CDLGAPSIDESIDEWHITE_StateFree( void** _state )
    TA_RetCode TA_CDLGAPSIDESIDEWHITE_StateInit( void** _state )
    TA_RetCode TA_CDLGAPSIDESIDEWHITE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLGAPSIDESIDEWHITE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLGAPSIDESIDEWHITE_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLGAPSIDESIDEWHITE_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLGAPSIDESIDEWHITE(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLGRAVESTONEDOJI_Lookback()
    TA_RetCode TA_CDLGRAVESTONEDOJI_StateFree( void** _state )
    TA_RetCode TA_CDLGRAVESTONEDOJI_StateInit( void** _state )
    TA_RetCode TA_CDLGRAVESTONEDOJI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLGRAVESTONEDOJI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLGRAVESTONEDOJI_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLGRAVESTONEDOJI_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLGRAVESTONEDOJI(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLHAMMER_Lookback()
    TA_RetCode TA_CDLHAMMER_StateFree( void** _state )
    TA_RetCode TA_CDLHAMMER_StateInit( void** _state )
    TA_RetCode TA_CDLHAMMER_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLHAMMER_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLHAMMER_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLHAMMER_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLHAMMER(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLHANGINGMAN_Lookback()
    TA_RetCode TA_CDLHANGINGMAN_StateFree( void** _state )
    TA_RetCode TA_CDLHANGINGMAN_StateInit( void** _state )
    TA_RetCode TA_CDLHANGINGMAN_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLHANGINGMAN_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLHANGINGMAN_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLHANGINGMAN_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLHANGINGMAN(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLHARAMICROSS_Lookback()
    TA_RetCode TA_CDLHARAMICROSS_StateFree( void** _state )
    TA_RetCode TA_CDLHARAMICROSS_StateInit( void** _state )
    TA_RetCode TA_CDLHARAMICROSS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLHARAMICROSS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLHARAMICROSS_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLHARAMICROSS_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLHARAMICROSS(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLHARAMI_Lookback()
    TA_RetCode TA_CDLHARAMI_StateFree( void** _state )
    TA_RetCode TA_CDLHARAMI_StateInit( void** _state )
    TA_RetCode TA_CDLHARAMI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLHARAMI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLHARAMI_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLHARAMI_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLHARAMI(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLHIGHWAVE_Lookback()
    TA_RetCode TA_CDLHIGHWAVE_StateFree( void** _state )
    TA_RetCode TA_CDLHIGHWAVE_StateInit( void** _state )
    TA_RetCode TA_CDLHIGHWAVE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLHIGHWAVE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLHIGHWAVE_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLHIGHWAVE_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLHIGHWAVE(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLHIKKAKEMOD_Lookback()
    TA_RetCode TA_CDLHIKKAKEMOD_StateFree( void** _state )
    TA_RetCode TA_CDLHIKKAKEMOD_StateInit( void** _state )
    TA_RetCode TA_CDLHIKKAKEMOD_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLHIKKAKEMOD_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLHIKKAKEMOD_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLHIKKAKEMOD_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLHIKKAKEMOD(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    
    int TA_CDLHIKKAKE_Lookback()
    TA_RetCode TA_CDLHIKKAKE_StateFree( void** _state )
    TA_RetCode TA_CDLHIKKAKE_StateInit( void** _state )
    TA_RetCode TA_CDLHIKKAKE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLHIKKAKE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLHIKKAKE_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLHIKKAKE_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLHIKKAKE(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLHOMINGPIGEON_Lookback()
    TA_RetCode TA_CDLHOMINGPIGEON_StateFree( void** _state )
    TA_RetCode TA_CDLHOMINGPIGEON_StateInit( void** _state )
    TA_RetCode TA_CDLHOMINGPIGEON_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLHOMINGPIGEON_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLHOMINGPIGEON_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLHOMINGPIGEON_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLHOMINGPIGEON(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLIDENTICAL3CROWS_Lookback()
    TA_RetCode TA_CDLIDENTICAL3CROWS_StateFree( void** _state )
    TA_RetCode TA_CDLIDENTICAL3CROWS_StateInit( void** _state )
    TA_RetCode TA_CDLIDENTICAL3CROWS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLIDENTICAL3CROWS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLIDENTICAL3CROWS_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLIDENTICAL3CROWS_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLIDENTICAL3CROWS(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLINNECK_Lookback()
    TA_RetCode TA_CDLINNECK_StateFree( void** _state )
    TA_RetCode TA_CDLINNECK_StateInit( void** _state )
    TA_RetCode TA_CDLINNECK_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLINNECK_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLINNECK_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLINNECK_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLINNECK(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLINVERTEDHAMMER_Lookback()
    TA_RetCode TA_CDLINVERTEDHAMMER_StateFree( void** _state )
    TA_RetCode TA_CDLINVERTEDHAMMER_StateInit( void** _state )
    TA_RetCode TA_CDLINVERTEDHAMMER_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLINVERTEDHAMMER_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLINVERTEDHAMMER_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLINVERTEDHAMMER_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLINVERTEDHAMMER(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLKICKINGBYLENGTH_Lookback()
    TA_RetCode TA_CDLKICKINGBYLENGTH_StateFree( void** _state )
    TA_RetCode TA_CDLKICKINGBYLENGTH_StateInit( void** _state )
    TA_RetCode TA_CDLKICKINGBYLENGTH_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLKICKINGBYLENGTH_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLKICKINGBYLENGTH_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLKICKINGBYLENGTH_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLKICKINGBYLENGTH(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLKICKING_Lookback()
    TA_RetCode TA_CDLKICKING_StateFree( void** _state )
    TA_RetCode TA_CDLKICKING_StateInit( void** _state )
    TA_RetCode TA_CDLKICKING_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLKICKING_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLKICKING_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLKICKING_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLKICKING(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLLADDERBOTTOM_Lookback()
    TA_RetCode TA_CDLLADDERBOTTOM_StateFree( void** _state )
    TA_RetCode TA_CDLLADDERBOTTOM_StateInit( void** _state )
    TA_RetCode TA_CDLLADDERBOTTOM_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLLADDERBOTTOM_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLLADDERBOTTOM_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLLADDERBOTTOM_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLLADDERBOTTOM(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLLONGLEGGEDDOJI_Lookback()
    TA_RetCode TA_CDLLONGLEGGEDDOJI_StateFree( void** _state )
    TA_RetCode TA_CDLLONGLEGGEDDOJI_StateInit( void** _state )
    TA_RetCode TA_CDLLONGLEGGEDDOJI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLLONGLEGGEDDOJI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLLONGLEGGEDDOJI_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLLONGLEGGEDDOJI_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLLONGLEGGEDDOJI(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLLONGLINE_Lookback()
    TA_RetCode TA_CDLLONGLINE_StateFree( void** _state )
    TA_RetCode TA_CDLLONGLINE_StateInit( void** _state )
    TA_RetCode TA_CDLLONGLINE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLLONGLINE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLLONGLINE_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLLONGLINE_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLLONGLINE(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLMARUBOZU_Lookback()
    TA_RetCode TA_CDLMARUBOZU_StateFree( void** _state )
    TA_RetCode TA_CDLMARUBOZU_StateInit( void** _state )
    TA_RetCode TA_CDLMARUBOZU_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLMARUBOZU_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLMARUBOZU_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLMARUBOZU_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLMARUBOZU(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLMATCHINGLOW_Lookback()
    TA_RetCode TA_CDLMATCHINGLOW_StateFree( void** _state )
    TA_RetCode TA_CDLMATCHINGLOW_StateInit( void** _state )
    TA_RetCode TA_CDLMATCHINGLOW_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLMATCHINGLOW_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLMATCHINGLOW_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLMATCHINGLOW_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLMATCHINGLOW(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLMATHOLD_Lookback(double optInPenetration)
    TA_RetCode TA_CDLMATHOLD_StateFree( void** _state )
    TA_RetCode TA_CDLMATHOLD_StateInit( void** _state, double optInPenetration )
    TA_RetCode TA_CDLMATHOLD_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLMATHOLD_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLMATHOLD_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLMATHOLD_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLMATHOLD(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], double optInPenetration, int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLMORNINGDOJISTAR_Lookback(double optInPenetration)
    TA_RetCode TA_CDLMORNINGDOJISTAR_StateFree( void** _state )
    TA_RetCode TA_CDLMORNINGDOJISTAR_StateInit( void** _state, double optInPenetration )
    TA_RetCode TA_CDLMORNINGDOJISTAR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLMORNINGDOJISTAR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLMORNINGDOJISTAR_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLMORNINGDOJISTAR_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLMORNINGDOJISTAR(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], double optInPenetration, int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLMORNINGSTAR_Lookback(double optInPenetration)
    TA_RetCode TA_CDLMORNINGSTAR_StateFree( void** _state )
    TA_RetCode TA_CDLMORNINGSTAR_StateInit( void** _state, double optInPenetration )
    TA_RetCode TA_CDLMORNINGSTAR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLMORNINGSTAR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLMORNINGSTAR_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLMORNINGSTAR_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLMORNINGSTAR(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], double optInPenetration, int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLONNECK_Lookback()
    TA_RetCode TA_CDLONNECK_StateFree( void** _state )
    TA_RetCode TA_CDLONNECK_StateInit( void** _state )
    TA_RetCode TA_CDLONNECK_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLONNECK_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLONNECK_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLONNECK_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLONNECK(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLPIERCING_Lookback()
    TA_RetCode TA_CDLPIERCING_StateFree( void** _state )
    TA_RetCode TA_CDLPIERCING_StateInit( void** _state )
    TA_RetCode TA_CDLPIERCING_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLPIERCING_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLPIERCING_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLPIERCING_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLPIERCING(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLRICKSHAWMAN_Lookback()
    TA_RetCode TA_CDLRICKSHAWMAN_StateFree( void** _state )
    TA_RetCode TA_CDLRICKSHAWMAN_StateInit( void** _state )
    TA_RetCode TA_CDLRICKSHAWMAN_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLRICKSHAWMAN_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLRICKSHAWMAN_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLRICKSHAWMAN_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLRICKSHAWMAN(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLRISEFALL3METHODS_Lookback()
    TA_RetCode TA_CDLRISEFALL3METHODS_StateFree( void** _state )
    TA_RetCode TA_CDLRISEFALL3METHODS_StateInit( void** _state )
    TA_RetCode TA_CDLRISEFALL3METHODS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLRISEFALL3METHODS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLRISEFALL3METHODS_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLRISEFALL3METHODS_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLRISEFALL3METHODS(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLSEPARATINGLINES_Lookback()
    TA_RetCode TA_CDLSEPARATINGLINES_StateFree( void** _state )
    TA_RetCode TA_CDLSEPARATINGLINES_StateInit( void** _state )
    TA_RetCode TA_CDLSEPARATINGLINES_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLSEPARATINGLINES_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLSEPARATINGLINES_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLSEPARATINGLINES_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLSEPARATINGLINES(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLSHOOTINGSTAR_Lookback()
    TA_RetCode TA_CDLSHOOTINGSTAR_StateFree( void** _state )
    TA_RetCode TA_CDLSHOOTINGSTAR_StateInit( void** _state )
    TA_RetCode TA_CDLSHOOTINGSTAR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLSHOOTINGSTAR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLSHOOTINGSTAR_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLSHOOTINGSTAR_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLSHOOTINGSTAR(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLSHORTLINE_Lookback()
    TA_RetCode TA_CDLSHORTLINE_StateFree( void** _state )
    TA_RetCode TA_CDLSHORTLINE_StateInit( void** _state )
    TA_RetCode TA_CDLSHORTLINE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLSHORTLINE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLSHORTLINE_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLSHORTLINE_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLSHORTLINE(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLSPINNINGTOP_Lookback()
    TA_RetCode TA_CDLSPINNINGTOP_StateFree( void** _state )
    TA_RetCode TA_CDLSPINNINGTOP_StateInit( void** _state )
    TA_RetCode TA_CDLSPINNINGTOP_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLSPINNINGTOP_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLSPINNINGTOP_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLSPINNINGTOP_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLSPINNINGTOP(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLSTALLEDPATTERN_Lookback()
    TA_RetCode TA_CDLSTALLEDPATTERN_StateFree( void** _state )
    TA_RetCode TA_CDLSTALLEDPATTERN_StateInit( void** _state )
    TA_RetCode TA_CDLSTALLEDPATTERN_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLSTALLEDPATTERN_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLSTALLEDPATTERN_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLSTALLEDPATTERN_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLSTALLEDPATTERN(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLSTICKSANDWICH_Lookback()
    TA_RetCode TA_CDLSTICKSANDWICH_StateFree( void** _state )
    TA_RetCode TA_CDLSTICKSANDWICH_StateInit( void** _state )
    TA_RetCode TA_CDLSTICKSANDWICH_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLSTICKSANDWICH_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLSTICKSANDWICH_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLSTICKSANDWICH_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLSTICKSANDWICH(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLTAKURI_Lookback()
    TA_RetCode TA_CDLTAKURI_StateFree( void** _state )
    TA_RetCode TA_CDLTAKURI_StateInit( void** _state )
    TA_RetCode TA_CDLTAKURI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLTAKURI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLTAKURI_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLTAKURI_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLTAKURI(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLTASUKIGAP_Lookback()
    TA_RetCode TA_CDLTASUKIGAP_StateFree( void** _state )
    TA_RetCode TA_CDLTASUKIGAP_StateInit( void** _state )
    TA_RetCode TA_CDLTASUKIGAP_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLTASUKIGAP_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLTASUKIGAP_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLTASUKIGAP_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLTASUKIGAP(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLTHRUSTING_Lookback()
    TA_RetCode TA_CDLTHRUSTING_StateFree( void** _state )
    TA_RetCode TA_CDLTHRUSTING_StateInit( void** _state )
    TA_RetCode TA_CDLTHRUSTING_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLTHRUSTING_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLTHRUSTING_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLTHRUSTING_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLTHRUSTING(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLTRISTAR_Lookback()
    TA_RetCode TA_CDLTRISTAR_StateFree( void** _state )
    TA_RetCode TA_CDLTRISTAR_StateInit( void** _state )
    TA_RetCode TA_CDLTRISTAR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLTRISTAR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLTRISTAR_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLTRISTAR_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLTRISTAR(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLUNIQUE3RIVER_Lookback()
    TA_RetCode TA_CDLUNIQUE3RIVER_StateFree( void** _state )
    TA_RetCode TA_CDLUNIQUE3RIVER_StateInit( void** _state )
    TA_RetCode TA_CDLUNIQUE3RIVER_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLUNIQUE3RIVER_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLUNIQUE3RIVER_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLUNIQUE3RIVER_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLUNIQUE3RIVER(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLUPSIDEGAP2CROWS_Lookback()
    TA_RetCode TA_CDLUPSIDEGAP2CROWS_StateFree( void** _state )
    TA_RetCode TA_CDLUPSIDEGAP2CROWS_StateInit( void** _state )
    TA_RetCode TA_CDLUPSIDEGAP2CROWS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLUPSIDEGAP2CROWS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLUPSIDEGAP2CROWS_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLUPSIDEGAP2CROWS_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLUPSIDEGAP2CROWS(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CDLXSIDEGAP3METHODS_Lookback()
    TA_RetCode TA_CDLXSIDEGAP3METHODS_StateFree( void** _state )
    TA_RetCode TA_CDLXSIDEGAP3METHODS_StateInit( void** _state )
    TA_RetCode TA_CDLXSIDEGAP3METHODS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CDLXSIDEGAP3METHODS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CDLXSIDEGAP3METHODS_State( void *_state, const double inOpen, const double inHigh, const double inLow, const double inClose, int *outInteger)
    TA_RetCode TA_CDLXSIDEGAP3METHODS_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_CDLXSIDEGAP3METHODS(int startIdx, int endIdx, const double inOpen[], const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_CEIL_Lookback()
    TA_RetCode TA_CEIL_StateFree( void** _state )
    TA_RetCode TA_CEIL_StateInit( void** _state )
    TA_RetCode TA_CEIL_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CEIL_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CEIL_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_CEIL_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_CEIL(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_CMO_Lookback(int optInTimePeriod)
    TA_RetCode TA_CMO_StateFree( void** _state )
    TA_RetCode TA_CMO_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_CMO_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CMO_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CMO_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_CMO_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_CMO(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_CORREL_Lookback(int optInTimePeriod)
    TA_RetCode TA_CORREL_StateFree( void** _state )
    TA_RetCode TA_CORREL_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_CORREL_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_CORREL_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_CORREL_State( void *_state, const double inReal0, const double inReal1, double *outReal)
    TA_RetCode TA_CORREL_BatchState( void *_state, int startIdx, int endIdx, const double inReal0[], const double inReal1[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_CORREL(int startIdx, int endIdx, const double inReal0[], const double inReal1[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_COSH_Lookback()
    TA_RetCode TA_COSH_StateFree( void** _state )
    TA_RetCode TA_COSH_StateInit( void** _state )
    TA_RetCode TA_COSH_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_COSH_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_COSH_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_COSH_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_COSH(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_COS_Lookback()
    TA_RetCode TA_COS_StateFree( void** _state )
    TA_RetCode TA_COS_StateInit( void** _state )
    TA_RetCode TA_COS_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_COS_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_COS_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_COS_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_COS(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_DEMA_Lookback(int optInTimePeriod)
    TA_RetCode TA_DEMA_StateFree( void** _state )
    TA_RetCode TA_DEMA_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_DEMA_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_DEMA_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_DEMA_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_DEMA_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_DEMA(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_DIV_Lookback()
    TA_RetCode TA_DIV_StateFree( void** _state )
    TA_RetCode TA_DIV_StateInit( void** _state )
    TA_RetCode TA_DIV_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_DIV_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_DIV_State( void *_state, const double inReal0, const double inReal1, double *outReal)
    TA_RetCode TA_DIV_BatchState( void *_state, int startIdx, int endIdx, const double inReal0[], const double inReal1[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_DIV(int startIdx, int endIdx, const double inReal0[], const double inReal1[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_DX_Lookback(int optInTimePeriod)
    TA_RetCode TA_DX_StateFree( void** _state )
    TA_RetCode TA_DX_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_DX_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_DX_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_DX_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_DX_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_DX(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_EMA_Lookback(int optInTimePeriod)
    TA_RetCode TA_EMA_StateFree( void** _state )
    TA_RetCode TA_EMA_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_EMA_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_EMA_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_EMA_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_EMA_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_EMA(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_EXP_Lookback()
    TA_RetCode TA_EXP_StateFree( void** _state )
    TA_RetCode TA_EXP_StateInit( void** _state )
    TA_RetCode TA_EXP_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_EXP_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_EXP_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_EXP_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_EXP(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_FLOOR_Lookback()
    TA_RetCode TA_FLOOR_StateFree( void** _state )
    TA_RetCode TA_FLOOR_StateInit( void** _state )
    TA_RetCode TA_FLOOR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_FLOOR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_FLOOR_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_FLOOR_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_FLOOR(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_HT_DCPERIOD_Lookback()
    TA_RetCode TA_HT_DCPERIOD_StateFree( void** _state )
    TA_RetCode TA_HT_DCPERIOD_StateInit( void** _state )
    TA_RetCode TA_HT_DCPERIOD_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_HT_DCPERIOD_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_HT_DCPERIOD_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_HT_DCPERIOD_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_HT_DCPERIOD(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_HT_DCPHASE_Lookback()
    TA_RetCode TA_HT_DCPHASE_StateFree( void** _state )
    TA_RetCode TA_HT_DCPHASE_StateInit( void** _state )
    TA_RetCode TA_HT_DCPHASE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_HT_DCPHASE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_HT_DCPHASE_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_HT_DCPHASE_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_HT_DCPHASE(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_HT_PHASOR_Lookback()
    TA_RetCode TA_HT_PHASOR_StateFree( void** _state )
    TA_RetCode TA_HT_PHASOR_StateInit( void** _state )
    TA_RetCode TA_HT_PHASOR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_HT_PHASOR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_HT_PHASOR_State( void *_state, const double inReal, double *outInPhase, double *outQuadrature)
    TA_RetCode TA_HT_PHASOR_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outInPhase[], double outQuadrature[])
    TA_RetCode TA_HT_PHASOR(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outInPhase[], double outQuadrature[])

    int TA_HT_SINE_Lookback()
    TA_RetCode TA_HT_SINE_StateFree( void** _state )
    TA_RetCode TA_HT_SINE_StateInit( void** _state )
    TA_RetCode TA_HT_SINE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_HT_SINE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_HT_SINE_State( void *_state, const double inReal, double *outSine, double *outLeadSine)
    TA_RetCode TA_HT_SINE_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outSine[], double outLeadSine[])
    TA_RetCode TA_HT_SINE(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outSine[], double outLeadSine[])

    int TA_HT_TRENDLINE_Lookback()
    TA_RetCode TA_HT_TRENDLINE_StateFree( void** _state )
    TA_RetCode TA_HT_TRENDLINE_StateInit( void** _state )
    TA_RetCode TA_HT_TRENDLINE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_HT_TRENDLINE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_HT_TRENDLINE_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_HT_TRENDLINE_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_HT_TRENDLINE(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_HT_TRENDMODE_Lookback()
    TA_RetCode TA_HT_TRENDMODE_StateFree( void** _state )
    TA_RetCode TA_HT_TRENDMODE_StateInit( void** _state )
    TA_RetCode TA_HT_TRENDMODE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_HT_TRENDMODE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_HT_TRENDMODE_State( void *_state, const double inReal, int *outInteger)
    TA_RetCode TA_HT_TRENDMODE_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_HT_TRENDMODE(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_IMI_Lookback(int optInTimePeriod)
    TA_RetCode TA_IMI_StateFree( void** _state )
    TA_RetCode TA_IMI_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_IMI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_IMI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_IMI_State( void *_state, const double inOpen, const double inClose, double *outReal)
    TA_RetCode TA_IMI_BatchState( void *_state, int startIdx, int endIdx, const double inOpen[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_IMI(int startIdx, int endIdx, const double inOpen[], const double inClose[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_KAMA_Lookback(int optInTimePeriod)
    TA_RetCode TA_KAMA_StateFree( void** _state )
    TA_RetCode TA_KAMA_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_KAMA_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_KAMA_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_KAMA_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_KAMA_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_KAMA(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_LINEARREG_ANGLE_Lookback(int optInTimePeriod)
    TA_RetCode TA_LINEARREG_ANGLE_StateFree( void** _state )
    TA_RetCode TA_LINEARREG_ANGLE_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_LINEARREG_ANGLE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_LINEARREG_ANGLE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_LINEARREG_ANGLE_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_LINEARREG_ANGLE_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_LINEARREG_ANGLE(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_LINEARREG_INTERCEPT_Lookback(int optInTimePeriod)
    TA_RetCode TA_LINEARREG_INTERCEPT_StateFree( void** _state )
    TA_RetCode TA_LINEARREG_INTERCEPT_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_LINEARREG_INTERCEPT_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_LINEARREG_INTERCEPT_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_LINEARREG_INTERCEPT_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_LINEARREG_INTERCEPT_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_LINEARREG_INTERCEPT(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_LINEARREG_SLOPE_Lookback(int optInTimePeriod)
    TA_RetCode TA_LINEARREG_SLOPE_StateFree( void** _state )
    TA_RetCode TA_LINEARREG_SLOPE_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_LINEARREG_SLOPE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_LINEARREG_SLOPE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_LINEARREG_SLOPE_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_LINEARREG_SLOPE_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_LINEARREG_SLOPE(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])
    
    int TA_LINEARREG_Lookback(int optInTimePeriod)
    TA_RetCode TA_LINEARREG_StateFree( void** _state )
    TA_RetCode TA_LINEARREG_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_LINEARREG_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_LINEARREG_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_LINEARREG_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_LINEARREG_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_LINEARREG(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_LN_Lookback()
    TA_RetCode TA_LN_StateFree( void** _state )
    TA_RetCode TA_LN_StateInit( void** _state )
    TA_RetCode TA_LN_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_LN_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_LN_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_LN_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_LN(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_LOG10_Lookback()
    TA_RetCode TA_LOG10_StateFree( void** _state )
    TA_RetCode TA_LOG10_StateInit( void** _state )
    TA_RetCode TA_LOG10_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_LOG10_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_LOG10_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_LOG10_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_LOG10(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MACDEXT_Lookback(int optInFastPeriod, TA_MAType optInFastMAType, int optInSlowPeriod, TA_MAType optInSlowMAType, int optInSignalPeriod, TA_MAType optInSignalMAType)
    TA_RetCode TA_MACDEXT_StateFree( void** _state )
    TA_RetCode TA_MACDEXT_StateInit( void** _state, int optInFastPeriod, TA_MAType optInFastMAType, int optInSlowPeriod, TA_MAType optInSlowMAType, int optInSignalPeriod, TA_MAType optInSignalMAType )
    TA_RetCode TA_MACDEXT_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MACDEXT_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MACDEXT_State( void *_state, const double inReal, double *outMACD, double *outMACDSignal, double *outMACDHist)
    TA_RetCode TA_MACDEXT_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outMACD[], double outMACDSignal[], double outMACDHist[])
    TA_RetCode TA_MACDEXT(int startIdx, int endIdx, const double inReal[], int optInFastPeriod, TA_MAType optInFastMAType, int optInSlowPeriod, TA_MAType optInSlowMAType, int optInSignalPeriod, TA_MAType optInSignalMAType, int *outBegIdx, int *outNBElement, double outMACD[], double outMACDSignal[], double outMACDHist[])

    int TA_MACDFIX_Lookback(int optInSignalPeriod)
    TA_RetCode TA_MACDFIX_StateFree( void** _state )
    TA_RetCode TA_MACDFIX_StateInit( void** _state, int optInSignalPeriod )
    TA_RetCode TA_MACDFIX_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MACDFIX_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MACDFIX_State( void *_state, const double inReal, double *outMACD, double *outMACDSignal, double *outMACDHist)
    TA_RetCode TA_MACDFIX_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outMACD[], double outMACDSignal[], double outMACDHist[])
    TA_RetCode TA_MACDFIX(int startIdx, int endIdx, const double inReal[], int optInSignalPeriod, int *outBegIdx, int *outNBElement, double outMACD[], double outMACDSignal[], double outMACDHist[])

    int TA_MACD_Lookback(int optInFastPeriod, int optInSlowPeriod, int optInSignalPeriod)
    TA_RetCode TA_MACD_StateFree( void** _state )
    TA_RetCode TA_MACD_StateInit( void** _state, int optInFastPeriod, int optInSlowPeriod, int optInSignalPeriod )
    TA_RetCode TA_MACD_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MACD_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MACD_State( void *_state, const double inReal, double *outMACD, double *outMACDSignal, double *outMACDHist)
    TA_RetCode TA_MACD_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outMACD[], double outMACDSignal[], double outMACDHist[])
    TA_RetCode TA_MACD(int startIdx, int endIdx, const double inReal[], int optInFastPeriod, int optInSlowPeriod, int optInSignalPeriod, int *outBegIdx, int *outNBElement, double outMACD[], double outMACDSignal[], double outMACDHist[])

    int TA_MAMA_Lookback(double optInFastLimit, double optInSlowLimit)
    TA_RetCode TA_MAMA_StateFree( void** _state )
    TA_RetCode TA_MAMA_StateInit( void** _state, double optInFastLimit, double optInSlowLimit )
    TA_RetCode TA_MAMA_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MAMA_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MAMA_State( void *_state, const double inReal, double *outMAMA, double *outFAMA)
    TA_RetCode TA_MAMA_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outMAMA[], double outFAMA[])
    TA_RetCode TA_MAMA(int startIdx, int endIdx, const double inReal[], double optInFastLimit, double optInSlowLimit, int *outBegIdx, int *outNBElement, double outMAMA[], double outFAMA[])
    
    int TA_MA_Lookback(int optInTimePeriod, TA_MAType optInMAType)
    TA_RetCode TA_MA_StateFree( void** _state )
    TA_RetCode TA_MA_StateInit( void** _state, int optInTimePeriod, TA_MAType optInMAType )
    TA_RetCode TA_MA_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MA_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MA_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_MA_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MA(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, TA_MAType optInMAType, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MAVP_Lookback(int optInMinPeriod, int optInMaxPeriod, TA_MAType optInMAType)
    TA_RetCode TA_MAVP_StateFree( void** _state )
    TA_RetCode TA_MAVP_StateInit( void** _state, int optInMinPeriod, int optInMaxPeriod, TA_MAType optInMAType )
    TA_RetCode TA_MAVP_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MAVP_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MAVP_State( void *_state, const double inReal, const double inPeriods, double *outReal)
    TA_RetCode TA_MAVP_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], const double inPeriods[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MAVP(int startIdx, int endIdx, const double inReal[], const double inPeriods[], int optInMinPeriod, int optInMaxPeriod, TA_MAType optInMAType, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MAXINDEX_Lookback(int optInTimePeriod)
    TA_RetCode TA_MAXINDEX_StateFree( void** _state )
    TA_RetCode TA_MAXINDEX_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MAXINDEX_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MAXINDEX_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MAXINDEX_State( void *_state, const double inReal, int *outInteger)
    TA_RetCode TA_MAXINDEX_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_MAXINDEX(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_MAX_Lookback(int optInTimePeriod)
    TA_RetCode TA_MAX_StateFree( void** _state )
    TA_RetCode TA_MAX_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MAX_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MAX_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MAX_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_MAX_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MAX(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MEDPRICE_Lookback()
    TA_RetCode TA_MEDPRICE_StateFree( void** _state )
    TA_RetCode TA_MEDPRICE_StateInit( void** _state )
    TA_RetCode TA_MEDPRICE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MEDPRICE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MEDPRICE_State( void *_state, const double inHigh, const double inLow, double *outReal)
    TA_RetCode TA_MEDPRICE_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MEDPRICE(int startIdx, int endIdx, const double inHigh[], const double inLow[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MFI_Lookback(int optInTimePeriod)
    TA_RetCode TA_MFI_StateFree( void** _state )
    TA_RetCode TA_MFI_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MFI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MFI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MFI_State( void *_state, const double inHigh, const double inLow, const double inClose, const double inVolume, double *outReal)
    TA_RetCode TA_MFI_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MFI(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], const double inVolume[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MIDPOINT_Lookback(int optInTimePeriod)
    TA_RetCode TA_MIDPOINT_StateFree( void** _state )
    TA_RetCode TA_MIDPOINT_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MIDPOINT_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MIDPOINT_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MIDPOINT_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_MIDPOINT_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MIDPOINT(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MIDPRICE_Lookback(int optInTimePeriod)
    TA_RetCode TA_MIDPRICE_StateFree( void** _state )
    TA_RetCode TA_MIDPRICE_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MIDPRICE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MIDPRICE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MIDPRICE_State( void *_state, const double inHigh, const double inLow, double *outReal)
    TA_RetCode TA_MIDPRICE_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MIDPRICE(int startIdx, int endIdx, const double inHigh[], const double inLow[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MININDEX_Lookback(int optInTimePeriod)
    TA_RetCode TA_MININDEX_StateFree( void** _state )
    TA_RetCode TA_MININDEX_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MININDEX_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MININDEX_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MININDEX_State( void *_state, const double inReal, int *outInteger)
    TA_RetCode TA_MININDEX_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, int outInteger[])
    TA_RetCode TA_MININDEX(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, int outInteger[])

    int TA_MINMAXINDEX_Lookback(int optInTimePeriod)
    TA_RetCode TA_MINMAXINDEX_StateFree( void** _state )
    TA_RetCode TA_MINMAXINDEX_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MINMAXINDEX_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MINMAXINDEX_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MINMAXINDEX_State( void *_state, const double inReal, int *outMinIdx, int *outMaxIdx)
    TA_RetCode TA_MINMAXINDEX_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, int outMinIdx[], int outMaxIdx[])
    TA_RetCode TA_MINMAXINDEX(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, int outMinIdx[], int outMaxIdx[])

    int TA_MINMAX_Lookback(int optInTimePeriod)
    TA_RetCode TA_MINMAX_StateFree( void** _state )
    TA_RetCode TA_MINMAX_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MINMAX_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MINMAX_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MINMAX_State( void *_state, const double inReal, double *outMin, double *outMax)
    TA_RetCode TA_MINMAX_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outMin[], double outMax[])
    TA_RetCode TA_MINMAX(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outMin[], double outMax[])
    
    int TA_MIN_Lookback(int optInTimePeriod)
    TA_RetCode TA_MIN_StateFree( void** _state )
    TA_RetCode TA_MIN_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MIN_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MIN_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MIN_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_MIN_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MIN(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MINUS_DI_Lookback(int optInTimePeriod)
    TA_RetCode TA_MINUS_DI_StateFree( void** _state )
    TA_RetCode TA_MINUS_DI_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MINUS_DI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MINUS_DI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MINUS_DI_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_MINUS_DI_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MINUS_DI(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MINUS_DM_Lookback(int optInTimePeriod)
    TA_RetCode TA_MINUS_DM_StateFree( void** _state )
    TA_RetCode TA_MINUS_DM_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MINUS_DM_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MINUS_DM_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MINUS_DM_State( void *_state, const double inHigh, const double inLow, double *outReal)
    TA_RetCode TA_MINUS_DM_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MINUS_DM(int startIdx, int endIdx, const double inHigh[], const double inLow[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MOM_Lookback(int optInTimePeriod)
    TA_RetCode TA_MOM_StateFree( void** _state )
    TA_RetCode TA_MOM_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_MOM_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MOM_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MOM_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_MOM_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MOM(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_MULT_Lookback()
    TA_RetCode TA_MULT_StateFree( void** _state )
    TA_RetCode TA_MULT_StateInit( void** _state )
    TA_RetCode TA_MULT_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_MULT_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_MULT_State( void *_state, const double inReal0, const double inReal1, double *outReal)
    TA_RetCode TA_MULT_BatchState( void *_state, int startIdx, int endIdx, const double inReal0[], const double inReal1[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_MULT(int startIdx, int endIdx, const double inReal0[], const double inReal1[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_NATR_Lookback(int optInTimePeriod)
    TA_RetCode TA_NATR_StateFree( void** _state )
    TA_RetCode TA_NATR_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_NATR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_NATR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_NATR_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_NATR_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_NATR(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_NVI_Lookback()
    TA_RetCode TA_NVI_StateFree( void** _state )
    TA_RetCode TA_NVI_StateInit( void** _state )
    TA_RetCode TA_NVI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_NVI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_NVI_State( void *_state, const double inClose, const double inVolume, double *outReal)
    TA_RetCode TA_NVI_BatchState( void *_state, int startIdx, int endIdx, const double inClose[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_NVI(int startIdx, int endIdx, const double inClose[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_OBV_Lookback()
    TA_RetCode TA_OBV_StateFree( void** _state )
    TA_RetCode TA_OBV_StateInit( void** _state )
    TA_RetCode TA_OBV_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_OBV_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_OBV_State( void *_state, const double inReal, const double inVolume, double *outReal)
    TA_RetCode TA_OBV_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_OBV(int startIdx, int endIdx, const double inReal[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_PLUS_DI_Lookback(int optInTimePeriod)
    TA_RetCode TA_PLUS_DI_StateFree( void** _state )
    TA_RetCode TA_PLUS_DI_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_PLUS_DI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_PLUS_DI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_PLUS_DI_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_PLUS_DI_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_PLUS_DI(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_PLUS_DM_Lookback(int optInTimePeriod)
    TA_RetCode TA_PLUS_DM_StateFree( void** _state )
    TA_RetCode TA_PLUS_DM_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_PLUS_DM_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_PLUS_DM_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_PLUS_DM_State( void *_state, const double inHigh, const double inLow, double *outReal)
    TA_RetCode TA_PLUS_DM_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_PLUS_DM(int startIdx, int endIdx, const double inHigh[], const double inLow[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_PPO_Lookback(int optInFastPeriod, int optInSlowPeriod, TA_MAType optInMAType)
    TA_RetCode TA_PPO_StateFree( void** _state )
    TA_RetCode TA_PPO_StateInit( void** _state, int optInFastPeriod, int optInSlowPeriod, TA_MAType optInMAType )
    TA_RetCode TA_PPO_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_PPO_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_PPO_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_PPO_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_PPO(int startIdx, int endIdx, const double inReal[], int optInFastPeriod, int optInSlowPeriod, TA_MAType optInMAType, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_PVI_Lookback()
    TA_RetCode TA_PVI_StateFree( void** _state )
    TA_RetCode TA_PVI_StateInit( void** _state )
    TA_RetCode TA_PVI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_PVI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_PVI_State( void *_state, const double inClose, const double inVolume, double *outReal)
    TA_RetCode TA_PVI_BatchState( void *_state, int startIdx, int endIdx, const double inClose[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_PVI(int startIdx, int endIdx, const double inClose[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_PVT_Lookback()
    TA_RetCode TA_PVT_StateFree( void** _state )
    TA_RetCode TA_PVT_StateInit( void** _state )
    TA_RetCode TA_PVT_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_PVT_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_PVT_State( void *_state, const double inClose, const double inVolume, double *outReal)
    TA_RetCode TA_PVT_BatchState( void *_state, int startIdx, int endIdx, const double inClose[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_PVT(int startIdx, int endIdx, const double inClose[], const double inVolume[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_ROCP_Lookback(int optInTimePeriod)
    TA_RetCode TA_ROCP_StateFree( void** _state )
    TA_RetCode TA_ROCP_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_ROCP_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ROCP_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ROCP_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_ROCP_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ROCP(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_ROCR100_Lookback(int optInTimePeriod)
    TA_RetCode TA_ROCR100_StateFree( void** _state )
    TA_RetCode TA_ROCR100_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_ROCR100_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ROCR100_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ROCR100_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_ROCR100_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ROCR100(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_ROCR_Lookback(int optInTimePeriod)
    TA_RetCode TA_ROCR_StateFree( void** _state )
    TA_RetCode TA_ROCR_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_ROCR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ROCR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ROCR_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_ROCR_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ROCR(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])
    
    int TA_ROC_Lookback(int optInTimePeriod)
    TA_RetCode TA_ROC_StateFree( void** _state )
    TA_RetCode TA_ROC_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_ROC_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ROC_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ROC_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_ROC_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ROC(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_RSI_Lookback(int optInTimePeriod)
    TA_RetCode TA_RSI_StateFree( void** _state )
    TA_RetCode TA_RSI_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_RSI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_RSI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_RSI_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_RSI_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_RSI(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_SAREXT_Lookback(double optInStartValue, double optInOffsetOnReverse, double optInAccelerationInitLong, double optInAccelerationLong, double optInAccelerationMaxLong, double optInAccelerationInitShort, double optInAccelerationShort, double optInAccelerationMaxShort)
    TA_RetCode TA_SAREXT_StateFree( void** _state )
    TA_RetCode TA_SAREXT_StateInit( void** _state, double optInStartValue, double optInOffsetOnReverse, double optInAccelerationInitLong, double optInAccelerationLong, double optInAccelerationMaxLong, double optInAccelerationInitShort, double optInAccelerationShort, double optInAccelerationMaxShort )
    TA_RetCode TA_SAREXT_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_SAREXT_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_SAREXT_State( void *_state, const double inHigh, const double inLow, double *outReal)
    TA_RetCode TA_SAREXT_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_SAREXT(int startIdx, int endIdx, const double inHigh[], const double inLow[], double optInStartValue, double optInOffsetOnReverse, double optInAccelerationInitLong, double optInAccelerationLong, double optInAccelerationMaxLong, double optInAccelerationInitShort, double optInAccelerationShort, double optInAccelerationMaxShort, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_SAR_Lookback(double optInAcceleration, double optInMaximum)
    TA_RetCode TA_SAR_StateFree( void** _state )
    TA_RetCode TA_SAR_StateInit( void** _state, double optInAcceleration, double optInMaximum )
    TA_RetCode TA_SAR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_SAR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_SAR_State( void *_state, const double inHigh, const double inLow, double *outReal)
    TA_RetCode TA_SAR_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_SAR(int startIdx, int endIdx, const double inHigh[], const double inLow[], double optInAcceleration, double optInMaximum, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_SINH_Lookback()
    TA_RetCode TA_SINH_StateFree( void** _state )
    TA_RetCode TA_SINH_StateInit( void** _state )
    TA_RetCode TA_SINH_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_SINH_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_SINH_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_SINH_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_SINH(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_SIN_Lookback()
    TA_RetCode TA_SIN_StateFree( void** _state )
    TA_RetCode TA_SIN_StateInit( void** _state )
    TA_RetCode TA_SIN_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_SIN_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_SIN_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_SIN_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_SIN(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_SMA_Lookback(int optInTimePeriod)
    TA_RetCode TA_SMA_StateFree( void** _state )
    TA_RetCode TA_SMA_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_SMA_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_SMA_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_SMA_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_SMA_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_SMA(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_SQRT_Lookback()
    TA_RetCode TA_SQRT_StateFree( void** _state )
    TA_RetCode TA_SQRT_StateInit( void** _state )
    TA_RetCode TA_SQRT_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_SQRT_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_SQRT_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_SQRT_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_SQRT(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_STDDEV_Lookback(int optInTimePeriod, double optInNbDev)
    TA_RetCode TA_STDDEV_StateFree( void** _state )
    TA_RetCode TA_STDDEV_StateInit( void** _state, int optInTimePeriod, double optInNbDev )
    TA_RetCode TA_STDDEV_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_STDDEV_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_STDDEV_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_STDDEV_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_STDDEV(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, double optInNbDev, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_STOCHF_Lookback(int optInFastK_Period, int optInFastD_Period, TA_MAType optInFastD_MAType)
    TA_RetCode TA_STOCHF_StateFree( void** _state )
    TA_RetCode TA_STOCHF_StateInit( void** _state, int optInFastK_Period, int optInFastD_Period, TA_MAType optInFastD_MAType )
    TA_RetCode TA_STOCHF_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_STOCHF_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_STOCHF_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outFastK, double *outFastD)
    TA_RetCode TA_STOCHF_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outFastK[], double outFastD[])
    TA_RetCode TA_STOCHF(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInFastK_Period, int optInFastD_Period, TA_MAType optInFastD_MAType, int *outBegIdx, int *outNBElement, double outFastK[], double outFastD[])

    int TA_STOCHRSI_Lookback(int optInTimePeriod, int optInFastK_Period, int optInFastD_Period, TA_MAType optInFastD_MAType)
    TA_RetCode TA_STOCHRSI_StateFree( void** _state )
    TA_RetCode TA_STOCHRSI_StateInit( void** _state, int optInTimePeriod, int optInFastK_Period, int optInFastD_Period, TA_MAType optInFastD_MAType )
    TA_RetCode TA_STOCHRSI_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_STOCHRSI_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_STOCHRSI_State( void *_state, const double inReal, double *outFastK, double *outFastD)
    TA_RetCode TA_STOCHRSI_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outFastK[], double outFastD[])
    TA_RetCode TA_STOCHRSI(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int optInFastK_Period, int optInFastD_Period, TA_MAType optInFastD_MAType, int *outBegIdx, int *outNBElement, double outFastK[], double outFastD[])
    
    int TA_STOCH_Lookback(int optInFastK_Period, int optInSlowK_Period, TA_MAType optInSlowK_MAType, int optInSlowD_Period, TA_MAType optInSlowD_MAType)
    TA_RetCode TA_STOCH_StateFree( void** _state )
    TA_RetCode TA_STOCH_StateInit( void** _state, int optInFastK_Period, int optInSlowK_Period, TA_MAType optInSlowK_MAType, int optInSlowD_Period, TA_MAType optInSlowD_MAType )
    TA_RetCode TA_STOCH_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_STOCH_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_STOCH_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outSlowK, double *outSlowD)
    TA_RetCode TA_STOCH_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outSlowK[], double outSlowD[])
    TA_RetCode TA_STOCH(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInFastK_Period, int optInSlowK_Period, TA_MAType optInSlowK_MAType, int optInSlowD_Period, TA_MAType optInSlowD_MAType, int *outBegIdx, int *outNBElement, double outSlowK[], double outSlowD[])

    int TA_SUB_Lookback()
    TA_RetCode TA_SUB_StateFree( void** _state )
    TA_RetCode TA_SUB_StateInit( void** _state )
    TA_RetCode TA_SUB_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_SUB_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_SUB_State( void *_state, const double inReal0, const double inReal1, double *outReal)
    TA_RetCode TA_SUB_BatchState( void *_state, int startIdx, int endIdx, const double inReal0[], const double inReal1[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_SUB(int startIdx, int endIdx, const double inReal0[], const double inReal1[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_SUM_Lookback(int optInTimePeriod)
    TA_RetCode TA_SUM_StateFree( void** _state )
    TA_RetCode TA_SUM_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_SUM_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_SUM_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_SUM_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_SUM_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_SUM(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_T3_Lookback(int optInTimePeriod, double optInVFactor)
    TA_RetCode TA_T3_StateFree( void** _state )
    TA_RetCode TA_T3_StateInit( void** _state, int optInTimePeriod, double optInVFactor )
    TA_RetCode TA_T3_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_T3_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_T3_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_T3_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_T3(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, double optInVFactor, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_TANH_Lookback()
    TA_RetCode TA_TANH_StateFree( void** _state )
    TA_RetCode TA_TANH_StateInit( void** _state )
    TA_RetCode TA_TANH_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_TANH_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_TANH_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_TANH_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_TANH(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_TAN_Lookback()
    TA_RetCode TA_TAN_StateFree( void** _state )
    TA_RetCode TA_TAN_StateInit( void** _state )
    TA_RetCode TA_TAN_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_TAN_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_TAN_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_TAN_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_TAN(int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_TEMA_Lookback(int optInTimePeriod)
    TA_RetCode TA_TEMA_StateFree( void** _state )
    TA_RetCode TA_TEMA_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_TEMA_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_TEMA_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_TEMA_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_TEMA_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_TEMA(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_TRANGE_Lookback()
    TA_RetCode TA_TRANGE_StateFree( void** _state )
    TA_RetCode TA_TRANGE_StateInit( void** _state )
    TA_RetCode TA_TRANGE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_TRANGE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_TRANGE_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_TRANGE_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_TRANGE(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_TRIMA_Lookback(int optInTimePeriod)
    TA_RetCode TA_TRIMA_StateFree( void** _state )
    TA_RetCode TA_TRIMA_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_TRIMA_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_TRIMA_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_TRIMA_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_TRIMA_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_TRIMA(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_TRIX_Lookback(int optInTimePeriod)
    TA_RetCode TA_TRIX_StateFree( void** _state )
    TA_RetCode TA_TRIX_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_TRIX_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_TRIX_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_TRIX_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_TRIX_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_TRIX(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_TSF_Lookback(int optInTimePeriod)
    TA_RetCode TA_TSF_StateFree( void** _state )
    TA_RetCode TA_TSF_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_TSF_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_TSF_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_TSF_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_TSF_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_TSF(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_TYPPRICE_Lookback()
    TA_RetCode TA_TYPPRICE_StateFree( void** _state )
    TA_RetCode TA_TYPPRICE_StateInit( void** _state )
    TA_RetCode TA_TYPPRICE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_TYPPRICE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_TYPPRICE_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_TYPPRICE_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_TYPPRICE(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_ULTOSC_Lookback(int optInTimePeriod1, int optInTimePeriod2, int optInTimePeriod3)
    TA_RetCode TA_ULTOSC_StateFree( void** _state )
    TA_RetCode TA_ULTOSC_StateInit( void** _state, int optInTimePeriod1, int optInTimePeriod2, int optInTimePeriod3 )
    TA_RetCode TA_ULTOSC_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_ULTOSC_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_ULTOSC_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_ULTOSC_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_ULTOSC(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInTimePeriod1, int optInTimePeriod2, int optInTimePeriod3, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_VAR_Lookback(int optInTimePeriod, double optInNbDev)
    TA_RetCode TA_VAR_StateFree( void** _state )
    TA_RetCode TA_VAR_StateInit( void** _state, int optInTimePeriod, double optInNbDev )
    TA_RetCode TA_VAR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_VAR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_VAR_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_VAR_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_VAR(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, double optInNbDev, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_WCLPRICE_Lookback()
    TA_RetCode TA_WCLPRICE_StateFree( void** _state )
    TA_RetCode TA_WCLPRICE_StateInit( void** _state )
    TA_RetCode TA_WCLPRICE_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_WCLPRICE_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_WCLPRICE_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_WCLPRICE_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_WCLPRICE(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])

    int TA_WILLR_Lookback(int optInTimePeriod)
    TA_RetCode TA_WILLR_StateFree( void** _state )
    TA_RetCode TA_WILLR_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_WILLR_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_WILLR_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_WILLR_State( void *_state, const double inHigh, const double inLow, const double inClose, double *outReal)
    TA_RetCode TA_WILLR_BatchState( void *_state, int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_WILLR(int startIdx, int endIdx, const double inHigh[], const double inLow[], const double inClose[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])

    int TA_WMA_Lookback(int optInTimePeriod)
    TA_RetCode TA_WMA_StateFree( void** _state )
    TA_RetCode TA_WMA_StateInit( void** _state, int optInTimePeriod )
    TA_RetCode TA_WMA_StateLoad( void** _state, FILE* _file )
    TA_RetCode TA_WMA_StateSave( void* _state, FILE* _file )
    TA_RetCode TA_WMA_State( void *_state, const double inReal, double *outReal)
    TA_RetCode TA_WMA_BatchState( void *_state, int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[])
    TA_RetCode TA_WMA(int startIdx, int endIdx, const double inReal[], int optInTimePeriod, int *outBegIdx, int *outNBElement, double outReal[])


    # TALIB functions for TA_SetUnstablePeriod
    TA_RetCode TA_SetUnstablePeriod(TA_FuncUnstId id, unsigned int unstablePeriod)
    unsigned int TA_GetUnstablePeriod(TA_FuncUnstId id)

    # TALIB functions for TA_SetCompatibility
    TA_RetCode TA_SetCompatibility(TA_Compatibility value)
    TA_Compatibility TA_GetCompatibility()

    # TALIB functions for TA_SetCandleSettings
    TA_RetCode TA_SetCandleSettings(TA_CandleSettingType settingType, TA_RangeType rangeType, int avgPeriod, double factor)
    TA_RetCode TA_RestoreCandleDefaultSettings(TA_CandleSettingType)

    TA_RetCode test(void* param)
