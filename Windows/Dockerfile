# Use the specified Windows base image
FROM mcr.microsoft.com/windows:10.0.17763.6659-amd64

# Define arguments for GitHub token and organization
ARG GH_TOKEN
ARG GH_ORG
ARG GH_REPO

# Copy the PowerShell scripts to the /tmp directory
COPY Deploy.ps1 /tmp/
COPY Setup.ps1 /tmp/

# Download Required Tools
ADD https://github.com/cli/cli/releases/download/v2.64.0/gh_2.64.0_windows_amd64.msi /tmp/gh_windows_amd64.msi
ADD https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/PowerShell-7.4.6-win-x64.msi /tmp/pwsh_windows_amd64.msi

# Install Tools
RUN powershell.exe -Command Start-Process -NoNewWindow -Wait -FilePath msiexec -ArgumentList '/i', 'C:\tmp\gh_windows_amd64.msi', '/quiet'
RUN powershell.exe -Command Start-Process -NoNewWindow -Wait -FilePath msiexec -ArgumentList '/i', 'C:\tmp\pwsh_windows_amd64.msi', '/quiet'

# Set the working directory
WORKDIR /tmp

# Create Token.txt, Org.txt and Repo.txt files with the contents of the ARGs
RUN echo %GH_TOKEN% > Token.txt && \
    echo %GH_ORG% > Org.txt && \
    echo %GH_REPO% > Repo.txt

# Entry point
ENTRYPOINT ["pwsh.exe", "-NoLogo", "-NonInteractive", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "./Deploy.ps1"]