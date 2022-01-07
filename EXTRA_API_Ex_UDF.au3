#cs ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Name..................: EXTRA_Extended_UDF
    Description...........: Custom extended UDF for EXTRA 3270 terminal emulator API
    Global dependencies...: Attachmate/Micro Focus EXTRA! X-treme 32-bit
							EXTRA_API_Core_UDF.au3

    Documentation.........: https://docs.attachmate.com/extra/x-treme/apis/com/

    Author................: exorcistas@github.com
    Modified..............: 2020-06-24
    Version...............: v1.0
#ce ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include-once
#include <EXTRA_API_Core_UDF.au3>

#Region FUNCTIONS_LIST
#cs	===================================================================================================================================
    _Extra_AttachActiveSession()
    _Extra_SendKeysAndWait($_oExtraScreen, $_sKeys, $_iRepeatTimes = 1)
	_Extra_SendEnter($_oExtraScreen)
	_Extra_EraseField($_oExtraScreen, $_iRow, $_iCol)
	_Extra_EraseFieldAndPutString($_oExtraScreen, $_sString, $_iRow, $_iCol)
	_Extra_FindStringRow($_oExtraScreen, $_sString, $_iStartRow = 1, $_iLastRow = "")
	_Extra_WaitScreenRefresh($_oExtraScreen, $_sExpectedTextOnScreen = "")
#ce	===================================================================================================================================
#EndRegion FUNCTIONS_LIST

#Region EXTRA_EXTENDED_FUNCTIONS
    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_AttachActiveSession()
        Description ...: Creates connection to active EXTRA session screen
        Syntax.........:
        Parameters.....:
        Return values..: Success - $_oScreen object
                         Failure - False + @error + @extended

        Author ........: exorcistas@github.com
        Modified.......: 2020-01-08
    #ce ===============================================================================================================================
    Func _Extra_AttachActiveSession()
        $_oExtra = _Extra_CreateObject()
            If @error Then Return SetError(@error, @extended, False)
        $_oSession = _Extra_GetActiveSessionObj($_oExtra)
            If @error Then Return SetError(@error, @extended, False)
        $_oScreen = _Extra_GetScreenObj($_oSession)
            If @error Then Return SetError(@error, @extended, False)
        
        Return $_oScreen
    EndFunc   ;=>_Extra_AttachActiveSession()

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_SendKeysAndWait()
        Description ...:
        Syntax.........:
        Parameters.....:
        Return values..:

        Author ........: exorcistas@github.com
        Modified.......: 2019-11-11
    #ce ===============================================================================================================================
    Func _Extra_SendKeysAndWait($_oExtraScreen, $_sKeys, $_iRepeatTimes = 1)
        If Not IsObj($_oExtraScreen) Then SetError(1, 1, False)

        For $i = 1 To $_iRepeatTimes
			_Extra_WaitHostQuiet($_oExtraScreen)
            _Extra_SendKeys($_oExtraScreen, $_sKeys)
            _Extra_WaitScreenRefresh($_oExtraScreen)
        Next
    EndFunc   ;=>_Extra_SendKeysAndWait()

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_SendEnter()
        Description ...:
        Syntax.........:
        Parameters.....:
        Return values..:

        Author ........: exorcistas@github.com
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
    Func _Extra_SendEnter($_oExtraScreen)
        If Not IsObj($_oExtraScreen) Then SetError(1, 1, False)

        _Extra_SendKeysAndWait($_oExtraScreen, "<Enter>")
    EndFunc   ;==>_Extra_SendEnter()

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_EraseField()
        Description ...:
        Syntax.........:
        Parameters.....:
        Return values..:

        Author ........: exorcistas@github.com
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
    Func _Extra_EraseField($_oExtraScreen, $_iRow, $_iCol)
        If Not IsObj($_oExtraScreen) Then SetError(1, 1, False)

		_Extra_WaitHostQuiet($_oExtraScreen)
        _Extra_MoveCursor($_oExtraScreen, $_iRow, $_iCol)

		_Extra_WaitHostQuiet($_oExtraScreen)
        _Extra_SendKeysAndWait($_oExtraScreen, "<EraseEOF>")
    EndFunc   ;==>_Extra_EraseField()

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_EraseFieldAndPutString()
        Description ...:
        Syntax.........:
        Parameters.....:
        Return values..:

        Author ........: exorcistas@github.com
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
    Func _Extra_EraseFieldAndPutString($_oExtraScreen, $_sString, $_iRow, $_iCol)
        If Not IsObj($_oExtraScreen) Then SetError(1, 1, False)

        _Extra_EraseField($_oExtraScreen, $_iRow, $_iCol)
		_Extra_WaitHostQuiet($_oExtraScreen)
        _Extra_PutString($_oExtraScreen, $_sString, $_iRow, $_iCol)
		_Extra_WaitHostQuiet($_oExtraScreen)

        If _Extra_GetString($_oExtraScreen, $_iRow, $_iCol, StringLen($_sString)) <> $_sString Then Return SetError(2, 1, False)

        Return True
    EndFunc   ;=>_Extra_EraseFieldAndPutString()

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_FindStringRow()
        Description ...:
        Syntax.........:
        Parameters.....:
        Return values..:

        Author ........: exorcistas@github.com
        Modified.......: 2019-11-07
    #ce ===============================================================================================================================
    Func _Extra_FindStringRow($_oExtraScreen, $_sString, $_iStartRow = 1, $_iLastRow = "")
        If Not IsObj($_oExtraScreen) Then SetError(1, 1, False)

        If $_iLastRow = "" Then $_iLastRow = $_oExtraScreen.Rows
            For $i = $_iStartRow To $_iLastRow
				_Extra_WaitHostQuiet($_oExtraScreen)
                $_sRowString = _Extra_GetString($_oExtraScreen, $i, 1, 80)
				_Extra_WaitHostQuiet($_oExtraScreen)

                If StringInStr($_sRowString,$_sString, 0) > 0 Then Return $i
            Next
        Return SetError(2, 1, -1)
    EndFunc   ;=>_Extra_FindStringRow()

    #cs #FUNCTION# ====================================================================================================================
        Name...........: _Extra_WaitScreenRefresh($_oExtraScreen, $_sExpectedTextOnScreen = "")
        Description ...:
        Syntax.........:
        Parameters.....:
        Return values..:

        Author ........: exorcistas@github.com
        Modified.......: 2019-11-11
    #ce ===============================================================================================================================
	Func _Extra_WaitScreenRefresh($_oExtraScreen, $_sExpectedTextOnScreen = "")
			Local $_icounter = 0

			Do
				_Extra_WaitHostQuiet($_oExtraScreen)
				$_icounter = $_icounter + 1
			Until $_oExtraScreen.Updated Or $_icounter >= 1000


			If $_sExpectedTextOnScreen <> "" Then
				_Extra_WaitHostQuiet($_oExtraScreen)
				$_iRow = _Extra_FindStringRow($_oExtraScreen, $_sExpectedTextOnScreen)
				If $_iRow = -1 Then
					Return SetError(1, 1, False)
				Else
					Return True
				EndIf

			ElseIf $_icounter >= 1000 Then
				Return SetError(2, 1, False)
			Else
				Return True
			EndIf
	EndFunc  ;=>_Extra_WaitScreenRefresh()
#EndRegion EXTRA_EXTENDED_FUNCTIONS