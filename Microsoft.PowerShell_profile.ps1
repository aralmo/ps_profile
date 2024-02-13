#set utf encoding
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

#oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\paradox.omp.json" | Invoke-Expression
Import-Module -Name Terminal-Icons
$env:ENVIRONMENT="DEV"
$env:OPENAI_TOKEN=""
# azure PAT
$MyPat = ""

function ll(){ 
    clear
    ls | fw -col 1
}

function recurse-replace($filter,$from,$to){    
    Get-ChildItem $filter -Recurse | ForEach-Object {
        (Get-Content $_).Replace($from,$to) | Set-Content $_
    }
}

function recurse-search($filter){    
    Get-ChildItem $filter -Recurse | ForEach-Object {
        echo (Get-Content $_)
    }
}

function replace-infile($file, $from, $to){
    (Get-Content $file).Replace($from,$to) | Set-Content $file
}




$B64Pat =  [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("`:$MyPat"))
$esc = [char]27
$gitc = [char]61906


function ll(){ 
    clear
    ls | fw -col 1
}
function gr(){
    cd ~/repo
}

$esc = [char]27

function gitBranchName {
    $currentBranch = ''
    git branch | foreach {
        if ($_ -match "^\* (.*)") {
            $currentBranch += $matches[1]
        }
    }
    $currentBranch
}

function prompt {
  $p = Split-Path -leaf -path (Get-Location)
  $b = gitBranchName

  "$p $esc[36m~$b$esc[0m> "
}

function Draw-Menu {
    param (
        [string]$Title = 'My Menu',
        [string[]]$Options = @('Option 1', 'Option 2', 'Option 3'),
        $Index = 0
    )
    cls
    Write-Host "================ $Title ================"
    $startIndex = [Math]::Floor($Index / 10) * 10
    $endIndex = [Math]::Min($startIndex + 9, $Options.Length - 1)
    for ($i = $startIndex; $i -le $endIndex; $i++) {
        if ($i -eq $Index) {
            Write-Host "$($Options[$i])" -ForegroundColor Green
        }
        else {
            Write-Host "$($Options[$i])"
        }
    }
}

function lk($term){
    $opts = get-childitem -recurse -filter *$term* -name -directory -depth 5
    $out = Choose -Title "Select Folder" -Options $opts;
    clear
    write-host $out
    cd $out
}

function gb($term){
    $b = git branch
    $selected = $null
    if($term){
        $b | foreach{
            if ($_.ToLower() -like "*$($term.ToLower())*") {
                $selected = $_.Trim();
            }
        }
    }
    
    if ($selected)
    {
        Write-Host "checking out branch: $($selected)"
    }else{
        $selected = choose -Title Branch -Options $b
    }

    git checkout $selected.Trim()
}

function Choose {
        param (
            [string]$Title = 'My Menu',
            [string[]]$Options = @('Option 1', 'Option 2', 'Option 3'),
            $Index = 0
        )

    $MenuIndex = 0

    if ($Options.Length -eq 1){
        return $Options[0]
    }
    
    if ($Options.Length -eq 0){
        return ''
    }

    do {
        Draw-Menu -Options $Options -Title $Title -Index $MenuIndex
        $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode
        switch ($key) {
            38 { # Up arrow
                if ($MenuIndex -gt 0) {
                    $MenuIndex--
                }
            }
            40 { # Down arrow
                if ($MenuIndex -lt ($Options.Length - 1)) {
                    $MenuIndex++
                }
            }
        }
    } until ($key -eq 13)
    $out = $Options[$MenuIndex]
    return "$out"
}