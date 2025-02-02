Attribute VB_Name = "Resolution"

Option Explicit

Private Const CCDEVICENAME          As Long = 32

Private Const CCFORMNAME            As Long = 32

Private Const DM_BITSPERPEL         As Long = &H40000

Private Const DM_PELSWIDTH          As Long = &H80000

Private Const DM_PELSHEIGHT         As Long = &H100000

Private Const DM_DISPLAYFREQUENCY   As Long = &H400000

Private Const CDS_TEST              As Long = &H4

Private Const ENUM_CURRENT_SETTINGS As Long = -1

Private Type typDevMODE

    dmDeviceName       As String * CCDEVICENAME
    dmSpecVersion      As Integer
    dmDriverVersion    As Integer
    dmSize             As Integer
    dmDriverExtra      As Integer
    dmFields           As Long
    dmOrientation      As Integer
    dmPaperSize        As Integer
    dmPaperLength      As Integer
    dmPaperWidth       As Integer
    dmScale            As Integer
    dmCopies           As Integer
    dmDefaultSource    As Integer
    dmPrintQuality     As Integer
    dmColor            As Integer
    dmDuplex           As Integer
    dmYResolution      As Integer
    dmTTOption         As Integer
    dmCollate          As Integer
    dmFormName         As String * CCFORMNAME
    dmUnusedPadding    As Integer
    dmBitsPerPel       As Integer
    dmPelsWidth        As Long
    dmPelsHeight       As Long
    dmDisplayFlags     As Long
    dmDisplayFrequency As Long

End Type

Private oldResHeight As Long

Private oldResWidth  As Long

Private oldDepth     As Integer

Private oldFrequency As Long

Private bResChange   As Boolean

Private Declare Function EnumDisplaySettings _
                Lib "user32" _
                Alias "EnumDisplaySettingsA" (ByVal lpszDeviceName As Long, _
                                              ByVal iModeNum As Long, _
                                              lptypDevMode As Any) As Boolean

Private Declare Function ChangeDisplaySettings _
                Lib "user32" _
                Alias "ChangeDisplaySettingsA" (lptypDevMode As Any, _
                                                ByVal dwFlags As Long) As Long

'TODO : Change this to not depend on any external public variable using args instead!

Public Sub SetResolution()
    
    On Error GoTo SetResolution_Err

    '***************************************************
    'Autor: Unknown
    'Last Modification: 03/29/08
    'Changes the display resolution if needed.
    'Last Modified By: Juan Mart�n Sotuyo Dodero (Maraxus)
    ' 03/29/2008: Maraxus - Retrieves current settings storing display depth and frequency for proper restoration.
    '***************************************************
    Dim lRes              As Long

    Dim MidevM            As typDevMODE

    Dim CambiarResolucion As Boolean

    Dim Width             As Integer

    Dim Height            As Integer
    
    lRes = EnumDisplaySettings(0, ENUM_CURRENT_SETTINGS, MidevM)
    
    oldResWidth = Screen.Width \ Screen.TwipsPerPixelX
    oldResHeight = Screen.Height \ Screen.TwipsPerPixelY
    
    #If ModoBig = 1 Then
        Width = 1920
        Height = 1080
    #ElseIf ModoBig = 2 Then
        Width = 1600
        Height = 900
    #Else
        Width = 800
        Height = 600
    #End If
    
    If ClientSetup.bConfig(eSetupMods.SETUP_PANTALLACOMPLETA) = 0 Then
        CambiarResolucion = (oldResWidth <= Width Or oldResHeight <= Height)
    Else
        CambiarResolucion = (oldResWidth <> Width Or oldResHeight <> Height)

    End If
    
    If CambiarResolucion Then
        
        With MidevM
            oldDepth = .dmBitsPerPel
            oldFrequency = .dmDisplayFrequency
            
            .dmFields = DM_PELSWIDTH Or DM_PELSHEIGHT Or DM_BITSPERPEL
            .dmPelsWidth = Width
            .dmPelsHeight = Height
            .dmBitsPerPel = 32

        End With
        
        lRes = ChangeDisplaySettings(MidevM, CDS_TEST)
        
        bResChange = True
        
        If FrmMain.visible Then FrmMain.Top = 0: FrmMain.Left = 0
    Else
        bResChange = False

    End If
    
    Exit Sub

SetResolution_Err:

    ' Call RegistrarError(err.Number, err.Description, "Resolution.SetResolution", Erl)
    Resume Next
    
End Sub

Public Sub ResetResolution()
    
    On Error GoTo ResetResolution_Err

    '***************************************************
    'Autor: Unknown
    'Last Modification: 03/29/08
    'Changes the display resolution if needed.
    'Last Modified By: Juan Mart�n Sotuyo Dodero (Maraxus)
    ' 03/29/2008: Maraxus - Properly restores display depth and frequency.
    '***************************************************
    Dim typDevM As typDevMODE

    Dim lRes    As Long
    
    If bResChange Then

        lRes = EnumDisplaySettings(0, ENUM_CURRENT_SETTINGS, typDevM)
        
        With typDevM
            .dmFields = DM_PELSWIDTH Or DM_PELSHEIGHT Or DM_BITSPERPEL Or DM_DISPLAYFREQUENCY
            .dmPelsWidth = oldResWidth
            .dmPelsHeight = oldResHeight
            .dmBitsPerPel = oldDepth
            .dmDisplayFrequency = oldFrequency

        End With
        
        lRes = ChangeDisplaySettings(typDevM, CDS_TEST)

    End If
    
    Exit Sub

ResetResolution_Err:

    ' Call RegistrarError(err.Number, err.Description, "Resolution.ResetResolution", Erl)
    Resume Next
    
End Sub

