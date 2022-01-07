#cs ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Name..................: EXTRA_API_UDF
    Description...........: UDF for EXTRA 3270 terminal emulator API
    Global dependencies...: Attachmate/Micro Focus EXTRA! X-treme
    Documentation.........: https://docs.attachmate.com/extra/x-treme/apis/com/

    Author................: exorcistas@github.com
    Modified..............: 2020-01-08
    Version...............: v1.0.6
#ce ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include-once
#include <Array.au3>
#include <File.au3>

#Region GLOBAL_VARIABLES
    Global Const $_EXTRA_ROOT_FOLDER = "C:\Program Files (x86)\micro focus\Extra!\"
    Global $_EXTRA_WAITHOSTTIME = 50
#EndRegion GLOBAL_VARIABLES

#Region FUNCTIONS_LIST
#cs	===================================================================================================================================
	_Extra_CreateObject()
	_Extra_GetActiveSessionObj($_oExtraApp)
	_Extra_ListAllSessions($_oExtraApp)
	_Extra_ActivateSession($_oExtraApp, $_sSession, $_bSetVisible = True)
	_Extra_GetScreenObj($_oExtraSession)
	_Extra_GetString($_oExtraScreen, $_iRow, $_iCol, $_iLength)
	_Extra_PutString($_oExtraScreen, $_sString, $_iRow, $_iCol)
	_Extra_WaitHostQuiet($_oExtraScreen, $_iWaitTime = $_g_iExtraWaitHostTime)
	_Extra_SendKeys($_oExtraScreen, $_sKeys)
	_Extra_MoveCursor($_oExtraScreen, $_iRow = 0, $_iCol = 0)
	_Extra_WaitForCursor($_oExtraScreen, $_iRow, $_iCol = "")
	_Extra_ListSessionFiles()
	_Extra_RunMainframeApp($_sSessionFullPath = $_EXTRA_ROOT_FOLDER & "EXTRA.exe")
#ce	===================================================================================================================================
#EndRegion FUNCTIONS_LIST

#Region CORE_API_FUNCTIONS
    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_CreateObject()
        Description ...: Creates object for Attachmate EXTRA! X-treme
        Syntax.........: https://docs.attachmate.com/extra/x-treme/apis/com/systemobject_con.htm
        Parameters.....:
        Return values..: Success - returns object value
                         Failure - returns FALSE, sets @error + @extended

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
        Func _Extra_CreateObject()
            Local $_sSystemName = "EXTRA.System"

            $_ProcID = ProcessExists("EXTRA.exe")
            If $_ProcID = 0 Then Return SetError(1, 1, False)

            Local $_oExtraApp = ObjCreate($_sSystemName)
                If @error Then Return SetError(@error, 2, False)

            Return $_oExtraApp
        EndFunc   ;==>_Extra_CreateObject

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_GetActiveSessionObj($_oExtraApp)
        Description ...: Returns EXTRA active session object
        Syntax.........: https://docs.attachmate.com/extra/x-treme/apis/com/activesessionproperty_con.htm
        Parameters.....: $_oExtraApp - EXTRA Application object
        Return values..: Success - returns object value
                         Failure - returns FALSE; sets @error + @extended

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
        Func _Extra_GetActiveSessionObj($_oExtraApp)
            If Not IsObj($_oExtraApp) Then Return SetError(1, 1, False)

            Return $_oExtraApp.ActiveSession
        EndFunc   ;==>_Extra_GetActiveSessionObj

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_ListAllSessions($_oExtraApp)
        Description ...: Returns all present sessions in array
        Syntax.........: https://docs.attachmate.com/extra/x-treme/apis/com/sessionsproperty_con.htm
        Parameters.....: $_oExtraApp - EXTRA Application object
        Return values..: Success - returns 2D array:
                                    array[0][0] - shows count of sessions;
                                    array[i][0] - session ID;
                                    array[i][1] - session name;
                                    array[i][2] - session full path;
                         Failure - returns FALSE; sets @error + @extended

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
        Func _Extra_ListAllSessions($_oExtraApp)
            If Not IsObj($_oExtraApp) Then SetError(1, 1, False)
            Local $_aExtraSessions[0][3]
            $_iSessionCount = $_oExtraApp.Sessions.Count
            _ArrayAdd($_aExtraSessions, $_iSessionCount)

            If $_iSessionCount = 0 Then Return $_aExtraSessions

            For $i = 1 To $_iSessionCount
                $_sSessItem = $_oExtraApp.Sessions.Item($i)
                _ArrayAdd($_aExtraSessions, $i & "|" & $_sSessItem.Name & "|" & $_sSessItem.FullName)
            Next

            Return $_aExtraSessions
        EndFunc   ;==>_Extra_ListAllSessions

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_ActivateSession($_oExtraApp, $_sSession, $_bSetVisible = True)
        Description ...: Activates EXTRA session based on name or ID
        Syntax.........: https://docs.attachmate.com/extra/x-treme/apis/com/activatemethod_con.htm
        Parameters.....: $_oExtraApp - EXTRA Application object
                         $_sSession - Session name or ID
                         $_bSetVisible - if True (DEFAULT), sets session to visible

        Return values..: Success - returns session object
                         Failure - returns FALSE, sets @error + @extended

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
        Func _Extra_ActivateSession($_oExtraApp, $_sSession, $_bSetVisible = True)
            If Not IsObj($_oExtraApp) Then Return SetError(1, 1, False)
            Local $_oExtraSession = $_oExtraApp.Sessions.Item($_sSession)
                If Not IsObj($_oExtraSession) Then SetError(1, 1, False)

            $_oExtraSession.Activate
            If $_bSetVisible Then $_oExtraSession.Visible = True

            Return $_oExtraSession
        EndFunc   ;==>_Extra_ActivateSession

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_GetScreenObj($_oExtraSession)
        Description ...: Returns Session Screen object
        Syntax.........: https://docs.attachmate.com/extra/x-treme/apis/com/screenobject_con.htm
        Parameters.....: $_oExtraSession - session object
        Return values..: Success - returns screen object
                         Failure - returns FALSE, sets @error + @extended

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
        Func _Extra_GetScreenObj($_oExtraSession)
            If Not IsObj($_oExtraSession) Then Return SetError(1, 1, False)

            Local $_oExtraScreen = $_oExtraSession.Screen
            Return $_oExtraScreen
        EndFunc   ;=>_Extra_GetScreenObj

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_GetString($_oExtraScreen, $_iRow, $_iCol, $_iLength)
        Description ...: Returns string based on row, column and length
        Syntax.........: https://docs.attachmate.com/extra/x-treme/apis/com/getstringmethod_con.htm
        Parameters.....: $_oExtraSession - session object; $_iRow, $_iCol, $_iLength
        Return values..: Success - returns string
                         Failure - returns FALSE, sets @error + @extended

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
        Func _Extra_GetString($_oExtraScreen, $_iRow, $_iCol, $_iLength)
            If Not IsObj($_oExtraScreen) Then Return SetError(1, 1, False)

            Local $_sString = $_oExtraScreen.GetString($_iRow, $_iCol, $_iLength)
            Return $_sString
        EndFunc   ;=>_Extra_GetString

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_PutString($_oExtraScreen, $_sString, $_iRow, $_iCol)
        Description ...: Sets text on screen based on row, column and length
        Syntax.........: https://docs.attachmate.com/extra/x-treme/apis/com/putstringmethod_con.htm
        Parameters.....: $_oExtraScreen - screen object; $_sString, $_iRow, $_iCol
        Return values..: Failure - returns FALSE, sets @error + @extended

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
        Func _Extra_PutString($_oExtraScreen, $_sString, $_iRow, $_iCol)
            If Not IsObj($_oExtraScreen) Then Return SetError(1, 1, False)

            $_oExtraScreen.PutString($_sString, $_iRow, $_iCol)
        EndFunc   ;=>_Extra_PutString

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_WaitHostQuiet($_oExtraScreen, $_iWaitTime = $_EXTRA_WAITHOSTTIME)
        Description ...: Waits for Extra application response
        Syntax.........: https://docs.attachmate.com/extra/x-treme/apis/com/waithostquietmethod_con.htm
        Parameters.....: $_oExtraScreen - screen object;
                         change global var $_EXTRA_WAITHOSTTIME in milliseconds

        Return values..: Failure - returns FALSE, sets @error + @extended

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-11
    #ce ===============================================================================================================================
        Func _Extra_WaitHostQuiet($_oExtraScreen, $_iWaitTime = $_EXTRA_WAITHOSTTIME)
            If Not IsObj($_oExtraScreen) Then Return SetError(1, 1, False)

            $_oExtraScreen.WaitHostQuiet($_EXTRA_WAITHOSTTIME)
        EndFunc   ;=>_Extra_WaitHostQuiet()

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_SendKeys($_oExtraScreen, $_sKeys)
        Description ...: Sends keyboard input
        Syntax.........: https://docs.attachmate.com/extra/x-treme/apis/com/3270functionkeys_des.htm
        Parameters.....: $_oExtraSession - session object;
                         $_sKeys - keys to send to screen
        Return values..: Failure - returns FALSE, sets @error + @extended

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-01
    #ce ===============================================================================================================================
        Func _Extra_SendKeys($_oExtraScreen, $_sKeys)
            If Not IsObj($_oExtraScreen) Then Return SetError(1, 1, False)

            $_oExtraScreen.SendKeys($_sKeys)
        EndFunc   ;=>_Extra_SendKeys

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_MoveCursor($_oExtraScreen, $_iRow = 0, $_iCol = 0)
        Description ...: Moves cursor on screen
        Syntax.........: https://docs.attachmate.com/extra/x-treme/apis/com/movetomethod_con.htm
        Parameters.....: $_oExtraSession - session object;
                         $_iRow, $_iCol - row and column coordinates
        Return values..: Failure - returns FALSE, sets @error + @extended

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
        Func _Extra_MoveCursor($_oExtraScreen, $_iRow = 0, $_iCol = 0)
            If Not IsObj($_oExtraScreen) Then Return SetError(1, 1, False)

            $_oExtraScreen.MoveTo($_iRow, $_iCol)
        EndFunc   ;=>_Extra_MoveCursor

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_WaitForCursor($_oExtraScreen, $_iRow, $_iCol = "")
        Description ...: Waits for cursor on screen at specific position/row
        Syntax.........: https://docs.attachmate.com/extra/x-treme/apis/com/waitforcursormethod_con.htm
        Parameters.....: $_oExtraSession - session object;
                         $_iRow, $_iCol - row and column coordinates
        Return values..: Failure - returns FALSE, sets @error + @extended

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
        Func _Extra_WaitForCursor($_oExtraScreen, $_iRow, $_iCol = "")
            If Not IsObj($_oExtraScreen) Then Return SetError(1, 1, False)

            $_oExtraScreen.WaitForCursor($_iRow, $_iCol)
        EndFunc   ;=>_Extra_WaitForCursor()

#EndRegion CORE_API_FUNCTIONS

#Region EXTRA_APP_FUNCTIONS

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_ListSessionFiles()
        Description ...: Lists *.edp session files in default directory of Attachmate EXTRA
        Syntax.........:
        Parameters.....:
        Return values..: Success - returns array with *.edp files listed

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
    Func _Extra_ListSessionFiles()
        $_sSessionDirectory = $_EXTRA_ROOT_FOLDER & "Sessions"
        $_aSessionFiles = _FileListToArray($_sSessionDirectory, "*.edp", 1, False)

        Return $_aSessionFiles
    EndFunc   ;=>_Extra_ListSessionFiles()

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_RunMainframeApp()
        Description ...: Runs instance of Attachmate EXTRA
        Syntax.........:
        Parameters.....:
        Return values..: Success - returns launched process ID

        Author ........: exorcistas@github.com 
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
    Func _Extra_RunMainframeApp($_sSessionFullPath = $_EXTRA_ROOT_FOLDER & "EXTRA.exe")
        $_iProcID = Run($_sSessionFullPath)

		Return $_iProcID
    EndFunc   ;=>_Extra_RunMainframeApp()
#EndRegion EXTRA_APP_FUNCTIONS
