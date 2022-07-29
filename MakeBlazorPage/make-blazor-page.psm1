function global:MakeBlazorPage() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[string]
		$PagePath,
		[Parameter(Mandatory = $true, Position = 1)]
		[string]
		$PageName,
		[Parameter(Mandatory = $false, Position = 2)]
		[string]
		$IncludeCss
	)

	if ($PSBoundParameters.ContainsKey("IncludeCss")) {
		[bool]$CreateCss = $IncludeCss
	}

	if (-not(Test-Path -Path .\$PagePath -PathType Container)) {
		throw "Page Path $PagePath does not exist";
	}

	$razorFile = "$PagePath\$PageName.razor";
	$csFile = "$PagePath\$PageName.razor.cs";
	$cssFile = "$PagePath\$PageName.razor.css";

	if ((Test-Path -Path $razorFile) -or (Test-Path -Path $csFile) -or ($CreateCss -and (Test-Path -Path $cssFile))) {
		throw "File(s) already exist in $PagePath"
	}

	$projFile = Get-ChildItem -path .\ -filter *.csproj -file | Select-Object -first 1
	$projName = $projFile.Name.replace('.csproj', '');

	if ($projName -eq '') {
		throw "No Project file found in current folder"
	}

	$namespace = "$($projName).";
	$namespace += $($PagePath.Replace('\', '.'));

	$csFileContents = [System.Text.StringBuilder]::new()
	[void]$csFileContents.Append("namespace $namespace")
	[void]$csFileContents.Append("{`n");
	[void]$csFileContents.Append("`tpublic partial class $PageName`n");
	[void]$csFileContents.Append("`t{`n");
	[void]$csFileContents.Append("`t}`n");
	[void]$csFileContents.Append("}`n");

	Set-Content -Path $razorFile -Value ""

	if ($CreateCss) {
		Set-Content -Path $cssFile -Value ""
	}
	Set-Content -Path $csFile -Value $csFileContents.ToString()
}

Export-ModuleMember -function MakeBlazorPage 
