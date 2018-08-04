# frozen_string_literal: true

SLACK_API_TOKEN = ''
SLACK_FILE_API_URL = 'https://slack.com/api/files.upload'
BCDICE_API_URL = ''

SHORTHANDS = <<~SHORTCUT.split("\n").map{|v| v.split(',') }.to_h.freeze
  DX,DoubleCross
  BI,BeginningIdol
  LHZ,LogHorizon
  GC,GranCrest
  ISN,Insane
  SW2,SwordWorld2.0
SHORTCUT
