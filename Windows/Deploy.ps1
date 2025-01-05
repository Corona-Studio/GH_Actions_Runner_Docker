$ErrorActionPreference = 'Stop'

# Read GitHub Token from Token.txt
$GH_TOKEN = (Get-Content Token.txt -TotalCount 1).Trim()

# Read GitHub Organization from Org.txt
$GH_ORG = (Get-Content Org.txt -TotalCount 1).Trim()

# Read GitHub Repository from Repo.txt
$GH_REPO = (Get-Content Repo.txt -TotalCount 1).Trim()

# Check if file self-hosted-runner/READY exists, if so, start self-hosted-runner/Run.cmd and wait to exit
if (Test-Path "self-hosted-runner/READY") {
    Start-Process "self-hosted-runner/run.cmd" -NoNewWindow -Wait
    exit 0
}

# Add GH_TOKEN to the environment variables
$env:GH_TOKEN = $GH_TOKEN

# Create directory
New-Item -Path "self-hosted-runner" -ItemType "directory" -Force

# Download GitHub self-hosted runner executable
$runnerDownloadsResponse = gh api `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    /orgs/$GH_ORG/actions/runners/downloads
$resJson = $runnerDownloadsResponse | ConvertFrom-Json
$matchedRunner = $resJson | Where-Object { $_.os -eq "win" -and $_.architecture -eq "x64" } | Select-Object -First 1
$runnerUrl = $matchedRunner.download_url

Write-Host "Downloading runner from $runnerUrl"

Invoke-WebRequest -Uri $runnerUrl -OutFile "self-hosted-runner/actions-runner-win-x64-2.164.0.zip"
Expand-Archive 'self-hosted-runner/actions-runner-win-x64-2.164.0.zip' -DestinationPath 'self-hosted-runner'

# Create the runner registration token
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$registrationTokenResponse = gh api `
    --method POST `
    -H "Accept: application/vnd.github+json" `
    -H "X-GitHub-Api-Version: 2022-11-28" `
    /repos/$GH_ORG/$GH_REPO/actions/runners/registration-token
$resJson = $registrationTokenResponse | ConvertFrom-Json
$registrationToken = $resJson.token

# Register the runner
Start-Process -FilePath "self-hosted-runner/config.cmd" `
    -NoNewWindow `
    -Wait `
    -ArgumentList `
    "--url", "https://github.com/$GH_ORG/$GH_REPO", `
    "--token", "$registrationToken", `
    "--name", "CS_BUILD_RUNNER_$timestamp", `
    "--unattended"

# Create a new self-hosted runner just-in-time configuration
# $timestamp = Get-Date -Format "yyyyMMddHHmmss"
# $jitConfigResponse = gh api -H "Accept: application/vnd.github+json" `
#     -H "X-GitHub-Api-Version: 2022-11-28" `
#     /orgs/$GH_ORG/actions/runners/generate-jitconfig `
#     -f "name=CS_BUILD_RUNNER_$timestamp" -F "runner_group_id=1" -f "labels[]=self-hosted"

# Write-Host "Runner config generated, runner name: CS_BUILD_RUNNER_$timestamp"

# # Extract the runner config JSON from the response
# $resJson = $jitConfigResponse | ConvertFrom-Json
# $jitConfigBytes = [System.Convert]::FromBase64String($resJson.encoded_jit_config)
# $jitConfig = [System.Text.Encoding]::UTF8.GetString($jitConfigBytes)
# $jitConfigJson = $jitConfig | ConvertFrom-Json

# # Write the runner config to disk (Except .credentials_rsaparams)
# $runnerBytes = [Convert]::FromBase64String($jitConfigJson.'.runner')
# Set-Content -Path "self-hosted-runner/.runner" -Value $runnerBytes -AsByteStream

# $credentialsBytes = [Convert]::FromBase64String($jitConfigJson.'.credentials')
# Set-Content -Path "self-hosted-runner/.credentials" -Value $credentialsBytes -AsByteStream

# # Write the .credentials_rsaparams to disk
# # Function to write a parameter with its length to a binary file
# function Write-BinaryParameter {
#     param (
#         [byte[]]$data,
#         [System.IO.BinaryWriter]$writer
#     )
#     # Write the length of the parameter (4 bytes, big-endian)
#     $lengthBytes = [BitConverter]::GetBytes([uint32]$data.Length)
#     [Array]::Reverse($lengthBytes)  # Convert to big-endian
#     $writer.Write($lengthBytes)
    
#     # Write the actual data
#     $writer.Write($data)
# }

# $stream = [System.IO.File]::OpenWrite("self-hosted-runner/.credentials_rsaparams")
# $writer = New-Object System.IO.BinaryWriter $stream

# $credentialsRsaparamsBytes = [Convert]::FromBase64String($jitConfigJson.'.credentials_rsaparams')
# $credentialsRsaparams = [System.Text.Encoding]::UTF8.GetString($credentialsRsaparamsBytes)
# $credentialsRsaparamsJson = $credentialsRsaparams | ConvertFrom-Json

# try {
#     foreach ($key in @("modulus", "exponent", "d", "p", "q", "dp", "dq", "inverseQ")) {
#         # Decode the Base64 string into a byte array
#         $decodedData = [Convert]::FromBase64String($credentialsRsaparamsJson.$key)
        
#         # Write the parameter to the file
#         Write-BinaryParameter -data $decodedData -writer $writer
#     }
# }
# finally {
#     # Close the writer and stream
#     $writer.Close()
#     $stream.Close()
# }

#$credentialsRsaparamsBytes = [Convert]::FromBase64String($jitConfigJson.'.credentials_rsaparams')
#Set-Content -Path "self-hosted-runner/.credentials_rsaparams" -Value $credentialsRsaparamsBytes -AsByteStream

#Write-Host "Runner config written to disk"

# Mark the runner as ready
New-Item -Path "self-hosted-runner/READY" -ItemType "file"

# Start the runner
Start-Process "self-hosted-runner/run.cmd" -NoNewWindow -Wait