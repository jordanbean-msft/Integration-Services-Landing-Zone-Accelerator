#!/usr/bin/env pwsh
# PowerShell equivalent of generate-tfvars.sh
# This script reads main.tfvars.json, replaces ${VAR} with environment variable values, and writes to terraform.tfvars.json

$ErrorActionPreference = "Stop"

$InputFile = "main.tfvars.json"
$OutputFile = "terraform.tfvars.json"

if (-not (Test-Path $InputFile)) {
    Write-Error "Input file $InputFile not found."
    exit 1
}

# Read the content of the input file
$content = Get-Content -Path $InputFile -Raw

# List all available environment variables for debugging
Write-Host "Available environment variables:"
Get-ChildItem env: | ForEach-Object { Write-Host "$($_.Name)=$($_.Value)" }

# Replace ${VAR} with the value of the environment variable VAR
$content = [regex]::Replace($content, '\$\{([A-Za-z_][A-Za-z0-9_]*)\}', {
    param($match)
    $varName = $match.Groups[1].Value
    Write-Host "Looking for environment variable: $varName"
    
    if (Test-Path "env:$varName") {
        $value = (Get-Item "env:$varName").Value
        Write-Host "Found value for ${varName}: $value"
        return $value
    } else {
        Write-Host "Environment variable $varName not found, keeping original placeholder"
        return $match.Value  # Keep the original if environment variable doesn't exist
    }
})

# Write the content to the output file
$content | Set-Content -Path $OutputFile -Encoding UTF8

Write-Host "Generated $OutputFile from $InputFile with environment variable substitutions."