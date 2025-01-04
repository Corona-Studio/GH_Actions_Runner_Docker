# Use the Windows Server image with Windows Container Runtime
FROM mcr.microsoft.com/windows:10.0.17763.6659-amd64

# ARGuments for GitHub Token and Organization Name
ARG GITHUB_TOKEN
ARG GITHUB_ORG

# Set environment variable for GitHub Token
ENV GH_TOKEN=${GITHUB_TOKEN}

# Install GitHub CLI using winget
RUN winget install --id GitHub.cli

# Generate JIT configuration for self-hosted runner
RUN powershell -Command "
$jit_config = gh api \
    --method POST \
    -H 'Accept: application/vnd.github+json' \
    -H 'X-GitHub-Api-Version: 2022-11-28' \
    /orgs/${GITHUB_ORG}/actions/runners/generate-jitconfig \
    -f 'name=CS_BUILD_RUNNER' -F 'runner_group_id=1' -f 'labels[0]=self-hosted'

$decoded_config = [ConvertFrom-Json]($jit_config.encoded_jit_config | ConvertFrom-Base64)
[System.IO.File]::WriteAllText('C:\\Runner\\config.json', $decoded_config)
"

# Download the latest self-hosted runner for Windows
RUN powershell -Command "
$runner_info = gh api \
    -H 'Accept: application/vnd.github+json' \
    -H 'X-GitHub-Api-Version: 2022-11-28' \
    /orgs/${GITHUB_ORG}/actions/runners/downloads

$download_url = $runner_info | Where-Object { $_.os -eq 'win' -and $_.architecture -eq 'x64' } | Select-Object -ExpandProperty download_url
Invoke-WebRequest -Uri $download_url -OutFile C:\\Runner\\runner.zip
Expand-Archive -Path C:\\Runner\\runner.zip -DestinationPath C:\\Runner
"

# Run the self-hosted runner
CMD [ "C:\\Runner\\svc.sh", "run" ]
