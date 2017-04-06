object frmMain: TfrmMain
  Left = 193
  Top = 108
  Caption = 'CSP Solver 1.0'
  ClientHeight = 562
  ClientWidth = 784
  Color = clBtnFace
  Font.Charset = ARABIC_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    784
    562)
  PixelsPerInch = 96
  TextHeight = 13
  object ExitBtn: TBitBtn
    Left = 700
    Top = 528
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Exit'
    TabOrder = 5
    OnClick = ExitBtnClick
  end
  object btnDomains: TBitBtn
    Left = 596
    Top = 528
    Width = 100
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Enter &Domains'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    OnClick = btnDomainsClick
  end
  object btnBTSolve: TBitBtn
    Left = 9
    Top = 528
    Width = 100
    Height = 25
    Hint = 'BackTraking Solving'
    Anchors = [akLeft, akBottom]
    Caption = '&BackTraking'
    Default = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnClick = btnBTSolveClick
  end
  object pgctlMain: TPageControl
    Left = 9
    Top = 8
    Width = 766
    Height = 513
    ActivePage = tabDefine
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tabDefine: TTabSheet
      Caption = '&Problem'
      DesignSize = (
        758
        485)
      object lblNodeCount: TLabel
        Left = 9
        Top = 9
        Width = 64
        Height = 13
        Caption = 'Node Count :'
      end
      object mtxGraph: TStringGrid
        Left = 5
        Top = 32
        Width = 318
        Height = 450
        Anchors = [akLeft, akTop, akBottom]
        ColCount = 8
        DefaultColWidth = 16
        DefaultRowHeight = 16
        RowCount = 8
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor]
        TabOrder = 4
        OnSetEditText = mtxGraphSetEditText
      end
      object mtxDomain: TStringGrid
        Left = 329
        Top = 95
        Width = 420
        Height = 387
        Anchors = [akLeft, akTop, akRight, akBottom]
        ColCount = 8
        DefaultColWidth = 38
        DefaultRowHeight = 18
        RowCount = 10
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor]
        TabOrder = 5
        ColWidths = (
          38
          38
          38
          38
          38
          38
          38
          38)
        RowHeights = (
          18
          18
          18
          18
          18
          18
          18
          18
          18
          18)
      end
      object edtNodeCount: TSpinEdit
        Left = 76
        Top = 6
        Width = 80
        Height = 22
        MaxValue = 26
        MinValue = 2
        TabOrder = 0
        Value = 6
        OnChange = edtNodeCountChange
      end
      object btnRandomize: TButton
        Left = 198
        Top = 6
        Width = 125
        Height = 22
        Caption = '&Randomize Graph'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = btnRandomizeClick
      end
      object rdogrpSelectVariable: TRadioGroup
        Left = 329
        Top = 6
        Width = 255
        Height = 83
        BiDiMode = bdLeftToRight
        Caption = ' Select Varaible '
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          'First To Last'
          'Last To First'
          'Most Degree '
          'MRV')
        ParentBiDiMode = False
        TabOrder = 2
        OnClick = rdogrpSelectVariableClick
      end
      object rdogrpSelectValue: TRadioGroup
        Left = 592
        Top = 6
        Width = 157
        Height = 83
        Anchors = [akLeft, akTop, akRight]
        BiDiMode = bdLeftToRight
        Caption = 'Select Value'
        ItemIndex = 0
        Items.Strings = (
          'First To Last'
          'Last To First')
        ParentBiDiMode = False
        TabOrder = 3
        OnClick = rdogrpSelectValueClick
      end
    end
    object tabResult: TTabSheet
      Caption = '&Solving result'
      ImageIndex = 1
      DesignSize = (
        758
        485)
      object imgGraph: TPaintBox
        Left = 3
        Top = 3
        Width = 512
        Height = 481
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = imgGraphPaint
        ExplicitWidth = 470
        ExplicitHeight = 420
      end
      object Label1: TLabel
        Left = 520
        Top = 2
        Width = 24
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Log: '
        ExplicitLeft = 478
      end
      object mmoSolveLog: TMemo
        Left = 520
        Top = 18
        Width = 233
        Height = 464
        Anchors = [akTop, akRight, akBottom]
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object btnBTFCSolve: TBitBtn
    Left = 112
    Top = 528
    Width = 125
    Height = 25
    Hint = 'BackTraking With ForwardChecking Solving'
    Anchors = [akLeft, akBottom]
    Caption = 'BT+&ForwardChecking'
    Default = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnClick = btnBTFCSolveClick
  end
  object btnArcConsitency: TBitBtn
    Left = 240
    Top = 528
    Width = 125
    Height = 25
    Hint = 'BackTraking With ForwardChecking Solving'
    Anchors = [akLeft, akBottom]
    Caption = 'BT+&Arc Consistency'
    Default = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = btnArcConsitencyClick
  end
end
