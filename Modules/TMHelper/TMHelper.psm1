#Uncomment to select which version of Studio you are using
#param([String]$StudioVersion = "Studio4")
param([String]$StudioVersion = "Studio5")

if ("${Env:ProgramFiles(x86)}") {
    $ProgramFilesDir = "${Env:ProgramFiles(x86)}"
}
else {
    $ProgramFilesDir = "${Env:ProgramFiles}"
}

Add-Type -Path "$ProgramFilesDir\SDL\SDL Trados Studio\$StudioVersion\Sdl.LanguagePlatform.TranslationMemoryApi.dll"
Add-Type -Path "$ProgramFilesDir\SDL\SDL Trados Studio\$StudioVersion\Sdl.LanguagePlatform.TranslationMemory.dll"


<#
	.DESCRIPTION
	Creates a new file based TM.
#>
function New-FileBasedTM
{
param( [String] $filePath,[String] $description, [String] $sourceLanguageName,
[String] $targetLanguageName,
[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes] $fuzzyIndexes,
[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers] $recognizers,
[Sdl.LanguagePlatform.Core.Tokenization.TokenizerFlags] $tokenizerFlags,
[Sdl.LanguagePlatform.TranslationMemory.WordCountFlags] $wordCountFlag)

$sourceLanguage = Get-CultureInfo $sourceLanguageName;
$targetLanguage = Get-CultureInfo $targetLanguageName;

[Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory] $tm = 
New-Object Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory ($filePath, $description, $sourceLanguage, $targetLanguage, $fuzzyIndexes, $recognizers, $tokenizerFlags, $wordCountFlag);   
}

function Open-FileBasedTM
{
	param([String] $filePath)
	[Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory] $tm = 
	New-Object Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory ($filePath);
	
	return $tm;
}

function Get-TargetTMLanguage
{
	param([String] $filePath)
	
	[Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory] $tm = Open-FileBasedTM $filePath;
	[Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemoryLanguageDirection] $direction = $tm.LanguageDirection;
	return $direction.TargetLanguage;	
}

function Get-Language
{
	param([String] $languageName)
	
	[Sdl.Core.Globalization.Language] $language = New-Object Sdl.Core.Globalization.Language ($languageName)
	return $language;
}

function Get-Languages
{
	param([String[]] $languageNames)
	[Sdl.Core.Globalization.Language[]]$languages = @();
	foreach($lang in $languageNames)
	{
		$newlang = Get-Language $lang;
		
		$languages = $languages + $newlang
	}

	return $languages
}

function Get-CultureInfo
{
	param([String] $languageName)
	$cultureInfo = Get-Language $languageName;
	return [System.Globalization.CultureInfo] $cultureInfo.CultureInfo;
}

function Get-DefaultFuzzyIndexes
{
	 return [Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::SourceCharacterBased -band 
	 	[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::SourceWordBased -band
		[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::TargetCharacterBased -band
		[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::TargetWordBased;
}

function Get-DefaultRecognizers
{
	return [Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeAcronyms -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeAll -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeDates -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeMeasurements -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeNumbers -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeTimes -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeVariables;
}

Export-ModuleMember New-FileBasedTM;
Export-ModuleMember Get-DefaultFuzzyIndexes;
Export-ModuleMember Get-DefaultRecognizers;
Export-ModuleMember Get-Language;
Export-ModuleMember Get-Languages;
Export-ModuleMember Open-FileBasedTM;
Export-ModuleMember Get-TargetTMLanguage;


