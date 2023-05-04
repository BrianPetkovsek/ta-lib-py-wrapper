import re
import os

class Argument:
    def __init__(self, argumentStr) -> None:
        self.argumentStr = argumentStr
        self.parse()
    
    def parse(self):
        argList = self.argumentStr.replace('*', '').replace('[]', '').split(' ')
        self.isArray = "[]" in self.argumentStr
        self.argName = argList[-1]
        self.argType = argList[-2]

    def __str__(self) -> str:
        return "<argName: {}, argType: {}, isArray: {}>".format(self.argName, self.argType, self.isArray)
    
    def __repr__(self):
        return self.__str__()
        

class Function:
    def __init__(self, reObj) -> None:
        self.reObj = reObj
        self.parse()
    
    def parse(self):
        argString = self.reObj.group(4)
        noWhiteSpace = re.compile(r'\s+')
        argList = [noWhiteSpace.sub(' ', i.strip()) for i in argString.split(',')]
        argList = [Argument(i) for i in argList if not (i == 'void' or i == '')]
        self.inArgList = []
        self.outArgList = []
        for i in argList:
            if i.argName.startswith('out'):
                self.outArgList.append(i)
            else:
                self.inArgList.append(i)
        
floatList = ['double', 'float']
intList = ['long', 'int', 'short']
class RTClass:
    def __init__(self, name: str, state: Function, stateInit: Function, stateFree: Function, stateSave: Function, stateLoad: Function, batchState: Function) -> None:
        self.name = name.replace('TA_', '')
        self.state = state
        self.stateInit = stateInit
        self.stateFree = stateFree
        self.stateSave = stateSave
        self.stateLoad = stateLoad
        self.batchState = batchState

    def buildClass(self) -> str:
        final = ''
        s = []
        s.append('import talibrt')
        s.append('from typing import List')
        s.append('')
        s.append('')
        s.append('class {}_RT:'.format(self.name))
        final += '\n'.join(s)
        s = ['']

        tmp = []
        for i in self.stateInit.inArgList:
            if i.argName == '_state': continue
            tplate = 'List[{}]'
            typee = '' 
            if i.argType in floatList:
                typee = 'float'
            elif i.argType in intList:
                typee = 'int'
            else:
                typee = "'{}'".format(i.argType)
            if i.isArray:
                typee = tplate.format(typee)

            tmp.append('{}: {}'.format(i.argName, typee))
        tmp.insert(0, 'self')
        s.append('def __init__({}):'.format(', '.join(tmp)))
        final += '\n\t'.join(s)
        s = ['']
        tmp = [i.argName for i in self.stateInit.inArgList if not i.argName == '_state']
        s.append('self.res, self._state = talibrt.{}{}({})'.format(self.name, '_StateInit', ', '.join(tmp)))
        final += '\n\t\t'.join(s)

        s = ['']
        s.append('')
        s.append('def __del__(self):')
        final += '\n\t'.join(s)

        s = ['']
        s.append('self.res = talibrt.{}{}({})'.format(self.name, '_StateFree', 'self._state'))
        final += '\n\t\t'.join(s)

        s = ['']
        s.append('')
        tmp = []
        for i in self.state.inArgList:
            if i.argName == '_state': continue
            tplate = 'List[{}]'
            typee = '' 
            if i.argType in floatList:
                typee = 'float'
            elif i.argType in intList:
                typee = 'int'
            else:
                typee = "'{}'".format(i.argType)
            if i.isArray:
                typee = tplate.format(typee)

            tmp.append('{}: {}'.format(i.argName, typee))
        tmp.insert(0, 'self')

        s.append('def state({}):'.format(', '.join(tmp)))
        final += '\n\t'.join(s)

        s = ['']
        tmp = [i.argName for i in self.state.inArgList if not i.argName == '_state']
        tmp.insert(0, 'self._state')
        s.append('self.res, *a = talibrt.{}{}({})'.format(self.name, '_State', ', '.join(tmp)))
        s.append('return a')
        final += '\n\t\t'.join(s)

        s = ['']
        s.append('')
        tmp = []
        for i in self.batchState.inArgList:
            if i.argName == '_state': continue
            elif i.argName == 'startIdx': continue
            elif i.argName == 'endIdx': continue
            tplate = 'List[{}]'
            typee = '' 
            if i.argType in floatList:
                typee = 'float'
            elif i.argType in intList:
                typee = 'int'
            else:
                typee = "'{}'".format(i.argType)
            if i.isArray:
                typee = tplate.format(typee)

            tmp.append('{}: {}'.format(i.argName, typee))
        tmp.insert(0, 'self')

        s.append('def batchState({}):'.format(', '.join(tmp)))
        final += '\n\t'.join(s)

        s = ['']
        tmp = [i.argName for i in self.batchState.inArgList if not i.argName == '_state']
        tmp.remove('startIdx')
        tmp.remove('endIdx')
        tmp.insert(0, 'self._state')
        s.append('self.res, *a = talibrt.{}{}({})'.format(self.name, '_BatchState', ', '.join(tmp)))
        s.append('return a')


        final += '\n\t\t'.join(s)

        return '{}_RT'.format(self.name), final


def gencode(path_ta_func_h):
    pattern = re.compile(r'([A-Za-z_]+) ([A-Za-z_]+) ([A-Za-z_]+)\(([^)]*)\);')
    with open(path_ta_func_h, 'r') as f:
        file_str = f.read()
    
    stateFunctions = {}
    stateInitFunctions = {}
    stateFreeFunctions = {}
    stateSaveFunctions = {}
    stateLoadFunctions = {}
    batchStateFunctions = {}
    functions = {}
    for match_obj in pattern.finditer(file_str):
        cmp = match_obj.group(3)
        if cmp.endswith('_State'):
            stateFunctions[cmp] = Function(match_obj)
        elif cmp.endswith('_StateInit'):
            stateInitFunctions[cmp] = Function(match_obj)
        elif cmp.endswith('_StateFree'):
            stateFreeFunctions[cmp] = Function(match_obj)
        elif cmp.endswith('_StateSave'):
            stateSaveFunctions[cmp] = Function(match_obj)
        elif cmp.endswith('_StateLoad'):
            stateLoadFunctions[cmp] = Function(match_obj)
        elif cmp.endswith('_BatchState'):
            batchStateFunctions[cmp] = Function(match_obj)
        else:
            functions[cmp] = Function(match_obj)
    
    os.makedirs('talibrt/rtgen', exist_ok=True)
    with open('talibrt/rtgen/__init__.py', 'w') as initFileF:
        for funcName, func in stateFunctions.items():
            name = funcName.replace('_State', '')
            state = func
            stateInit = stateInitFunctions[name+'_StateInit']
            stateFree = stateFreeFunctions[name+'_StateFree']
            stateSave = stateSaveFunctions[name+'_StateSave']
            stateLoad = stateLoadFunctions[name+'_StateLoad']
            batchState = batchStateFunctions[name+'_BatchState']
            a = RTClass(name, state, stateInit, stateFree, stateSave, stateLoad, batchState)
            className, fileContents = a.buildClass()
            initFileF.write('from .{} import {}\n'.format(className, className))
            with open('talibrt/rtgen/{}.py'.format(className), 'w') as classFileF:
                classFileF.write(fileContents)
            

if __name__ == '__main__':
    here = os.path.abspath(os.path.dirname(__file__))
    include_paths = here+'/../ta-lib-rt/c/include'
    ta_func_header = os.path.join(include_paths, 'ta-lib-rt', 'ta_func.h')
    gencode(ta_func_header)