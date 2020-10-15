
# https://communary.net/2016/09/26/consoleextensions-update-now-with-more-colors/
# Reference: https://github.com/Jaykul/PowerLine
# https://gist.github.com/bgelens/f9aa8b376bee90e9f38a06f28e254319#file-powerline-config-ps1
# https://github.com/PoshCode/Pansies - 1.4.0 required
# https://www.nickjames.ca/my-environment-my-powershell-profile/
# http://joonro.github.io/blog/posts/powershell-customizations.html

#Set-Variable -Scope Global -Name IsAdmin -Value $(New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
#
#if(Get-Module PowerLine -ListAvailable){
#	#	Import-module PowerLine
#	[PoshCode.Pansies.Entities]::ExtendedCharacters.Separator = $([char]0x2572)	
#	[System.Collections.Generic.List[ScriptBlock]]$global:Prompt = @(
#		{New-PromptText {Get-Elapsed -Format "{0:mm\m\ ss\.ffff}s" } -ErrorBackgroundColor DarkRed -ErrorForegroundColor White -ForegroundColor White -BackgroundColor DarkGray  },
#		{New-PromptText {Get-Date -f "HH:mm:ss"} -ForegroundColor Black -BackgroundColor Gray  },
#		{New-PromptText { $($MyInvocation.HistoryId) } -ForegroundColor White -BackgroundColor 'DarkGray'},
#		#{New-PromptText { $($MyInvocation.HistoryId) } -ForegroundColor White -BackgroundColor 'DarkBlue'},
#		{ if ($Global:IsAdmin) {New-PromptText {"wurzel"} -BackgroundColor DarkRed -ForegroundColor LightGray }else {New-PromptText { [environment]::UserName } -BackgroundColor Gray -ForegroundColor Black} },
#		{New-PromptText { "$($Env:COMPUTERNAME.ToLower())" } -ForegroundColor DarkGray -BackgroundColor Yellow},
#		{New-PromptText { ((Get-SegmentedPath) -join " $([PoshCode.Pansies.Entities]::ExtendedCharacters["Separator"]) ").Replace("$env:HOMEDRIVE\"," /") } -ForegroundColor White -BackgroundColor 'DarkBlue'},
#		{ if((Get-Acl (Get-Location).Path).AreAccessRulesProtected -eq $True) {New-PromptText { " $([PoshCode.Pansies.Entities]::ExtendedCharacters["Lock"]) " } -BackgroundColor 'DarkBlue' -ForegroundColor White } }
#		{ if(Get-Module psgit -ListAvailable) {New-PromptText { Get-GitStatusPowerline } -BackgroundColor DarkGray -ForegroundColor White}  }
#	)
#	
#	$Script:PowerLinePrompt = $global:Prompt
#	Set-PowerLinePrompt -SetCurrentDirectory -RestoreVirtualTerminal -FullColor -Prompt $global:Prompt -PowerLineFont -Title { 
#		$title ="PS PID: {0}" -f $PID
#		if(Test-Elevation){
#			"Admin - $title"
#		} else {
#			$title
#		}
#	} -Colors DarkRed, Black, DarkGray, DarkBlue, Cyan, Yellow, DarkBlue
#}
$Duration=Get-Elapsed -Format "{0:mm\m\ ss\.ffff}s"
function global:prompt {
    $pwd = $ExecutionContext.SessionState.Path.CurrentLocation
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "powerline-go"
    $startInfo.Arguments = "-shell bare"
    $startInfo.Environment["TERM"] = "xterm-256color"
    $startInfo.CreateNoWindow = $true
    $startInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $startInfo.RedirectStandardOutput = $true
    $startInfo.UseShellExecute = $false
    $startInfo.WorkingDirectory = $pwd
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $process.Start() | Out-Null
    $standardOut = $process.StandardOutput.ReadToEnd()
    $process.WaitForExit()
    $standardOut
}

$env:PYTHONIOENCODING = "UTF-8"

if(Get-Command -Name "git"){
	Set-Alias -Name "yadm" -Value "git"
}

if(Test-Path "$env:USERPROFILE\.psdotfiles"){ 
	#Import-Module $PSScriptRoot\ConsoleExtensions\ConsoleExtensions.psd1
	$dotfiles=Get-ChildItem "$env:USERPROFILE\.psdotfiles" -Depth 1 | ?{$_.Name -match ".ps1$" }
	$dotfiles | %{ . (Resolve-Path "$($_.FullName)" ) }
	#https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Script-Inspire-0c163df6
	Get-Quote
}

if((Get-Module 'PSFzf' -ListAvailable) -and (Get-Command fzf*.exe)){
	#https://github.com/kelleyma49/PSFzf
	Remove-PSReadlineKeyHandler 'Ctrl+r'
	Import-Module PSFzf -ArgumentList 'Ctrl+t','Ctrl+r'
}

if($PSVersionTable.PSVersion.Major -ge 5){
	#https://github.com/adamdriscoll/powershim
	#https://github.com/omniomi/AdvancedHistory
	#Add-WindowsPSModulePath
	Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
	Set-PSReadlineOption -ShowToolTips
	Set-PSReadlineOption -BellStyle None
}
#Set-Location C:\Scripts
