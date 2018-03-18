#PowerShell
#Requires -Version 3


Function ConvertTo-Translit {
    <#
    .SYNOPSIS
        Function for transliteration russian symbols with standards and rules.

    .DESCRIPTION
        Function for transliteration russian symbols with standards and rules.
        .

    .PARAMETER String
        String for transliteration.

    .PARAMETER Standard
        Standard name for transliteration.

    .LINK
        https://github.com/alseg/ConvertTo-Translit

    .NOTES
        ToDo-List:
        * Task

    .EXAMPLE
        PS> ConvertTo-Translit -String "Иванов Пётр Геннадьевич" -Standard gost-r-52535.1-2006
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]$String,

        [Parameter()]
        [ValidateSet("bgn-pcgn-1947", "gost-r-52535.1-2006")]
        [String]$Standard = "bgn-pcgn-1947"
    )


    Function Start-Main {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory)]
            [String]$String,

            [Parameter(Mandatory)]
            [Hashtable]$StandardSet
        )


        [Array]$String = $String.Split(" ")
        [Array]$NewString, [Array]$NewWordArray = @()

        ForEach ($Word in $String) {
            ForEach ($Char in $Word.ToCharArray()) {
                If (($Char -eq "Е") -and ($Previous -eq "Ь")) {
                    $NewWordArray += $StandardSet["ЬЕ"]
                }
                Else {
                    $NewWordArray += $StandardSet["$Char"]
                }
                [String]$Previous = $Char
            }
            [String]$WordCommit = $NewWordArray -join ""
            $NewWordArray = @()
            [Array]$StringCommit += $WordCommit
            $WordCommit = @()
        }
        Return $StringCommit -join " "
    }


    $BGN_PCGN_1947 = @{
            "А" = "A";
            "Б" = "B";
            "В" = "V";
            "Г" = "G";
            "Д" = "D";
            "Е" = "E";
            "Ё" = "E";
            "Ж" = "ZH";
            "З" = "Z";
            "И" = "I";
            "Й" = "Y";
            "К" = "K";
            "Л" = "L";
            "М" = "M";
            "Н" = "N";
            "О" = "O";
            "П" = "P";
            "Р" = "R";
            "С" = "S";
            "Т" = "T";
            "У" = "U";
            "Ф" = "F";
            "Х" = "KH";
            "Ц" = "TS";
            "Ч" = "CH";
            "Ш" = "SH";
            "Щ" = "SHCH";
            "Ь" = "";
            "Ы" = "Y";
            "" = "";
            "Э" = "E";
            "Ю" = "YU";
            "Я" = "YA";
            "ЬЕ" = "YE"
        }

    $GOST_R_52535_1_2006 = @{
            "А" = "A";
            "Б" = "B";
            "В" = "V";
            "Г" = "G";
            "Д" = "D";
            "Е" = "E";
            "Ё" = "E";
            "Ж" = "ZH";
            "З" = "Z";
            "И" = "I";
            "Й" = "I";
            "К" = "K";
            "Л" = "L";
            "М" = "M";
            "Н" = "N";
            "О" = "O";
            "П" = "P";
            "Р" = "R";
            "С" = "S";
            "Т" = "T";
            "У" = "U";
            "Ф" = "F";
            "Х" = "KH";
            "Ц" = "TC";
            "Ч" = "CH";
            "Ш" = "SH";
            "Щ" = "SHCH";
            "Ь" = "";
            "Ы" = "Y";
            "Ъ" = "";
            "Э" = "E";
            "Ю" = "IU";
            "Я" = "IA";
            "ЬЕ" = "E"
    }

    Switch($Standard) {
        "gost-r-52535.1-2006" {
            $Result = (Start-Main -String $String -StandardSet $GOST_R_52535_1_2006)
        }
        Default {
            $Result = (Start-Main -String $String -StandardSet $BGN_PCGN_1947)
        }
    }

    Return $Result
}