Option Explicit

'********************************************************************
' 機能名  ：TEST.VBS
' 機能概要：移行
' 作成    ：2016/09/05       新規作成
' 更新    ：
'********************************************************************

on error resume next
    
    '■定数宣言
    Const SRC = "TEST.VBS"

    '■移行処理の呼び出し
    Call MainConv(WScript.Arguments)

    '■エラーハンドリング後、VBSを終了する
    If 0 <> err.Number Then
        Call WScript.Echo( "VBS-" & CStr(err.Number) & " [" & err.Source & ":" & err.Description & "]" )
        Call WScript.Quit(1)
    Else
        Call WScript.Echo( "    ■■■■ 正常終了しました。 ■■■■" )
        Call WScript.Quit(0)
    End If

'**************************************
' 移行処理
'**************************************
Sub MainConv(argv)
    
    Dim objADO
    Dim srvName, dbName, loginName, loginPass
    Dim strSql
    Dim rsReturn
    Dim strSQL1
    Dim objADO1
    Dim srvName1, dbName1, loginName1, loginPass1

    ' 移行元データベース
    srvName = "A20422"              ' 移行元サーバ
    dbName = "YUUSI_LHF"            ' 移行元データベース
    loginName = "yuusi_lhf"         ' 移行元データベースへログインID
    loginPass = "yuusi_lhf"         ' 移行元データベースへパスワード
 
    'ADOを使いSQL ServerのDBを開く
    Set objADO = CreateObject("ADODB.Connection")
    objADO.Open "Driver={SQL Server};" & _
                "server=" & srvName & "; database=" & dbName & "; uid=" & loginName & "; pwd=" & loginPass & ";"

    ' 移行先データベース
    srvName1 = "A13464"             ' 移行先サーバ
    dbName1 = "YUUSI_LHF_DEV"       ' 移行先データベース
    loginName1 = "yuusi_lhf"        ' 移行先データベースへログインID
    loginPass1 = "yuusi_lhf"        ' 移行先データベースへパスワード
    
    'ADOを使いSQL ServerのDBを開く
    Set objADO1 = CreateObject("ADODB.Connection")
    objADO1.Open "Driver={SQL Server};" & _
                "server=" & srvName1 & "; database=" & dbName1 & "; uid=" & loginName1 & "; pwd=" & loginPass1 & ";"

    '抽出SQL文作成
    strSql = ""
    strSql = strSql & "SELECT                   " & vbCrLf
    strSql = strSql & "      syain_cd           " & vbCrLf
    strSql = strSql & "    , syain_nm           " & vbCrLf
    strSql = strSql & "    , mail_id            " & vbCrLf
    strSql = strSql & "    , busyo_nm           " & vbCrLf
    strSql = strSql & "    , yakuwari           " & vbCrLf
    strSql = strSql & "    , gyoumu_kbn         " & vbCrLf
    strSql = strSql & "    , touroku_nitiji     " & vbCrLf
    strSql = strSql & "    , touroku_syain_cd   " & vbCrLf
    strSql = strSql & " FROM MST_USER           " & vbCrLf
    strSql = strSql & "ORDER BY syain_cd        " & vbCrLf
    
    ' 抽出処理を行う
    Set rsReturn = objADO.Execute("" & strSql & "")

    

    '挿入SQL文作成
    strSQL1 = ""
    strSQL1 = strSQL1 & "INSERT INTO MST_USER     " & vbCrLf
    strSQL1 = strSQL1 & "    ( syain_cd           " & vbCrLf
    strSQL1 = strSQL1 & "    , syain_nm           " & vbCrLf
    strSQL1 = strSQL1 & "    , mail_id            " & vbCrLf
    strSQL1 = strSQL1 & "    , busyo_nm           " & vbCrLf
    strSQL1 = strSQL1 & "    , yakuwari           " & vbCrLf
    strSQL1 = strSQL1 & "    , gyoumu_kbn         " & vbCrLf
    strSQL1 = strSQL1 & "    , touroku_nitiji     " & vbCrLf
    strSQL1 = strSQL1 & "    , touroku_syain_cd ) " & vbCrLf
    strSQL1 = strSQL1 & "VALUES (                 " & vbCrLf

    ' レコード毎に移行先へ送付
    Do While rsReturn.EOF = False
        
        strSql = ""
        strSql = strSql & strSQL1 & vbCrLf
        strSql = strSql & IsNull(rsReturn.Fields.Item("syain_cd"), 0) & vbCrLf
        strSql = strSql & IsNull(rsReturn.Fields.Item("syain_nm"), 0) & vbCrLf
        strSql = strSql & IsNull(rsReturn.Fields.Item("mail_id"), 0)  & vbCrLf
        strSql = strSql & IsNull(rsReturn.Fields.Item("busyo_nm"), 0) & vbCrLf
        strSql = strSql & IsNull(rsReturn.Fields.Item("yakuwari"), 0) & vbCrLf
        strSql = strSql & IsNull(rsReturn.Fields.Item("gyoumu_kbn"), 0) & vbCrLf
        strSql = strSql & IsNull(rsReturn.Fields.Item("touroku_nitiji"), 0) & vbCrLf
        strSql = strSql & IsNull(rsReturn.Fields.Item("touroku_syain_cd"), 1) & vbCrLf

		' 移行先に挿入
        objADO1.Execute("" & strSql & "")
        
        ' 次のレコードへ
        rsReturn.MoveNext
    Loop

    'メモリ解放
    rsReturn.Close
    Set rsReturn = Nothing
    objADO.Close
    Set objADO = Nothing
    objADO1.Close
    Set objADO1 = Nothing

End Sub

'**************************************
'NULL判定処理
'**************************************
Function IsNull(value, flag)

    If value.Value = NULL Then
    	If flag = 0 Then
    		IsNull = "NULL, " 
    	Else
        	IsNull = "NULL) " 
        End If
    Else
    	If flag = 0 Then
    		IsNull = "'" & value.Value & "', " 
    	Else
        	IsNull = "'" & value.Value & "') "  
        End If
    End If
    
End Function



[?2016/?09/?05 16:52] 王 義国(yiguo wang): 
'■移行処理の呼び出し
    Call MainConv(WScript.Arguments)

    '■エラーハンドリング後、VBSを終了する
    If 0 <> err.Number Then
        Call WScript.Echo( "VBS-" & CStr(err.Number) & " [" & err.Source & ":" & err.Description & "]" )
        Call WScript.Quit(1)
    Else
        Call WScript.Echo( "    ■■■■ 表１移行完了しました。 ■■■■" )
    End If

    '■移行処理の呼び出し
    Call MainConv1(WScript.Arguments)

    '■エラーハンドリング後、VBSを終了する
    If 0 <> err.Number Then
        Call WScript.Echo( "VBS-" & CStr(err.Number) & " [" & err.Source & ":" & err.Description & "]" )
        Call WScript.Quit(1)
    Else
        Call WScript.Echo( "    ■■■■ 正常終了しました。 ■■■■" )
        Call WS
'■移行処理の呼び出し
    Call MainConv(WScript.Arguments)

    '■エラーハンドリング後、VBSを終了する
    If 0 <> err.Number Then
        Call WScript.Echo( "VBS-" & CStr(err.Number) & " [" & err.Source & ":" & err.Description & "]" )
        Call WScript.Quit(1)
    Else
        Call WScript.Echo( "    ■■■■ 表１移行完了しました。 ■■■■" )
    End If

    '■移行処理の呼び出し
    Call MainConv1(WScript.Arguments)

    '■エラーハンドリング後、VBSを終了する
    If 0 <> err.Number Then
        Call WScript.Echo( "VBS-" & CStr(err.Number) & " [" & err.Source & ":" & err.Description & "]" )
        Call WScript.Quit(1)
    Else
        Call WScript.Echo( "    ■■■■ 正常終了しました。 ■■■■" )
        Call WScript.Quit(0)
    End If


'■移行処理の呼び出し
    Call MainConv1(WScript.Arguments)

    '■エラーハンドリング後、VBSを終了する
    If 0 <> err.Number Then
        Call WScript.Echo( "VBS-" & CStr(err.Number) & " [" & err.Source & ":" & err.Description & "]" )
        Call WScript.Quit(1)
    Else
        Call WScript.Echo( "    ■■■■ 正常終了しました。 ■■■■" )
        Call WScript.Quit(0)
    End If
不是最后一个的?候
Call MainConv(WScript.Arguments)

    '■エラーハンドリング後、VBSを終了する
    If 0 <> err.Number Then
        Call WScript.Echo( "VBS-" & CStr(err.Number) & " [" & err.Source & ":" & err.Description & "]" )
        Call WScript.Quit(1)
    Else
        Call WScript.Echo( "    ■■■■ 表１移行完了しました。 ■■■■" )
    End If
