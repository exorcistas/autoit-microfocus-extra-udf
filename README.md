# MicroFocus/Attachmate Extra! API UDF

## Table of Contents
+ [About](#about)
+ [Prerequisites](#prerequisites)
+ [Installation](#installation)
+ [Usage](#usage)
+ [Documentation](#documentation)


## About <a name = "about"></a>
This UDF is an AutoIt wrapper for 'MicroFocus/Attachmate Extra!' 3270 terminal emulator.   
It uses exposed COM objects to communicate to emulator on application level.  
```Note, that not all functionality might be mapped or updated in current published version.```

## Prerequisites <a name = "prerequisites"></a>
```
User must have 'MicroFocus/Attachmate Extra!' 32-bit application installed with COM objects exposed.
```  

## Installation <a name = "installation"></a>
Simply copy ```.au3``` files to your development directory and use ```#include``` to point to these files in the source code.  

## Usage <a name = "usage"></a>
* Use ```EXTRA_API_*_UDF.au3``` for base functionality to 3270 emulator.   

## Documentation <a name = "documentation"></a>
* [Extra! emulator API documentation](https://docs.attachmate.com/extra/x-treme/apis/com/)