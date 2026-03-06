# Sample Dockerfile for Windows container testing
FROM mcr.microsoft.com/windows/servercore:ltsc2022
SHELL ["powershell", "-Command"]
RUN Write-Host 'Hello from container build test'
COPY app.txt C:/app/app.txt
CMD ["powershell", "-Command", "Get-Content C:/app/app.txt"]
