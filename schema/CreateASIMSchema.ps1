# Specify the root directory to start recursing from

$scriptDirectory = $PSScriptRoot

$rootDirectory = "$($scriptDirectory)\ASIM"

# Set the character limit for each output file
$charLimit = 110000
# Initialize file counter and character count
$fileCounter = 1
$charCount = 0

# Initialize the output file name
$outputFileBase = "$($scriptDirectory)\ASIM\ASIM"
$outputFile = "$outputFileBase$fileCounter.kql"

# Function to create a new output file and reset character count
function Create-NewOutputFile {
    param (
        [int]$counter,
        [ref]$outputFile,
        [ref]$charCount
    )
    $outputFile.Value = "$outputFileBase$counter.kql"
    $charCount.Value = 0

    # Create the file if it doesn't exist
    if (-not (Test-Path -Path $outputFile.Value)) {
        New-Item -Path $outputFile.Value -ItemType File | Out-Null
    } else {
        # Ensure the file is empty
        Clear-Content -Path $outputFile.Value
    }
}

# Create the initial output file
Create-NewOutputFile -counter $fileCounter -outputFile ([ref]$outputFile) -charCount ([ref]$charCount)

# Get all directories in the root directory and recurse alphabetically
$directories = Get-ChildItem -Path $rootDirectory -Directory -Recurse | Sort-Object Name

foreach ($directory in $directories) {
    # Get all .kql files in the current directory
    $kqlFiles = Get-ChildItem -Path $directory.FullName -Filter *.kql

    foreach ($kqlFile in $kqlFiles) {
        # Read the content of the .kql file
        $content = Get-Content -Path $kqlFile.FullName -Raw

        # Check if adding the content would exceed the character limit
        if (($charCount + $content.Length) -gt $charLimit) {
            # Create a new output file if the limit is exceeded
            $fileCounter++
            Create-NewOutputFile -counter $fileCounter -outputFile ([ref]$outputFile) -charCount ([ref]$charCount)
        }

        # Append the content to the output file
        Add-Content -Path $outputFile -Value $content

        # Add a new line to separate the content of different files
        Add-Content -Path $outputFile -Value "`n"

        # Update the character count
        $charCount += $content.Length
    }
}

Write-Output "Processing complete. The contents have been written to incremental files based on the character limit."
