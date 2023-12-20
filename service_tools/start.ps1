# Receive first positional argument
$FunctionName=$ARGS[0]
$arguments=@()
if ($ARGS.Length -gt 1) {
    $arguments = $ARGS[1..($ARGS.Length - 1)]
}

$script_dir_rel = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$script_dir = (Get-Item $script_dir_rel).FullName

$ADDON_VERSION = Invoke-Expression -Command "python -c ""import os;import sys;content={};f=open(r'$($script_dir)/../version.py');exec(f.read(),content);f.close();print(content['__version__'])"""

function defaultfunc {
  Write-Host ""
  Write-Host "*************************"
  Write-Host "AYON ftrack services tool"
  Write-Host "   Run ftrack services"
  Write-Host "*************************"
  Write-Host ""
  Write-Host "Run service processes from terminal. It is recommended to use docker images for production."
  Write-Host ""
  Write-Host "Usage: start [target]"
  Write-Host ""
  Write-Host "Optional arguments for service targets:"
  Write-Host "--variant [variant] (Define settings variant. default: 'production')"
  Write-Host ""
  Write-Host "Runtime targets:"
  Write-Host "  install    Install requirements to currently actie python (recommended to create venv)"
  Write-Host "  leecher    Start leecher of ftrack events"
  Write-Host "  processor  Main processing logic"
  Write-Host ""
}

function install {
  # TODO Install/verify venv is created
  & python -m pip install -r "$($script_dir)\requirements.txt"
}

function run_leecher {
  & python "$($script_dir)\main.py" --service leecher @arguments
}

function run_processor {
  & python "$($script_dir)\main.py" --service processor @arguments
}

function load-env {
  $env_path = "$($script_dir)/.env"
  if (Test-Path $env_path) {
    Get-Content $env_path | foreach {
      $name, $value = $_.split("=")
      if (-not([string]::IsNullOrWhiteSpace($name) -or $name.Contains("#"))) {
        Set-Content env:\$name $value
      }
    }
  }
}

function ActivateVenv {
  # Make sure venv is created
  $venv_path = "$($script_dir)\venv"
  if (-not(Test-Path $venv_path)) {
    & python -m venv $venv_path
  }
  & "$($venv_path)\Scripts\activate.ps1"
}

function main {
  $env:AYON_ADDON_NAME = "ftrack"
  $env:AYON_ADDON_VERSION = $ADDON_VERSION
  load-env
  ActivateVenv

  try {
    if ($FunctionName -eq "install") {
      install
    } elseif ($FunctionName -eq "leecher") {
      run_leecher
    } elseif ($FunctionName -eq "processor") {
      run_processor
    } elseif ($FunctionName -eq $null) {
      defaultfunc
    } else {
      Write-Host "Unknown function ""$FunctionName"""
    }
  } finally {
    & deactivate
  }
}

main