#PowerShell
#Requires -Version 3.0


function ConvertTo-Translit {
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

    .PARAMETER Format
        Format for output, "as is" by default.

    .LINK
        https://github.com/alseg/ConvertTo-Translit

    .NOTES
        .

    .EXAMPLE
        ConvertTo-Translit -String "ИвАн фёДОрОвИч КрУзеншТеРН"

        IvAn feDOrOvIch KrUzenshTeRN

    .EXAMPLE
        ConvertTo-Translit -String "ИвАн фёДОрОвИч КрУзеншТеРН" -Standard gost-r-52535.1-2006

        IvAn feDOrOvIch KrUzenshTeRN
    .EXAMPLE
        ConvertTo-Translit -String "ИвАн фёДОрОвИч КрУзеншТеРН" -Format Uppercase -Standard gost-r-52535.1-2006

        IVAN FEDOROVICH KRUZENSHTERN
    .EXAMPLE
        "ИвАн фёДОрОвИч КрУзеншТеРН", "пеЧкИН ИгОРЬ ИВАновиЧ" | ConvertTo-Translit

        IvAn feDOrOvIch KrUzenshTeRN
        peCHkIN IgOR IVAnoviCH
    .EXAMPLE
        "ИвАн фёДОрОвИч КрУзеншТеРН", "пеЧкИН ИгОРЬ ИВАновиЧ" | ConvertTo-Translit -Format Capitalize -Standard bgn-pcgn-1947

        Ivan Fedorovich Kruzenshtern
        Pechkin Igor Ivanovich
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,
        ValueFromPipeline,
        HelpMessage = "Enter string for transliteration")]
        [String]
        $String,

        [Parameter()]
        [ValidateSet("bgn-pcgn-1947", "gost-r-52535.1-2006")]
        [String]
        $Standard = "bgn-pcgn-1947",

        [Parameter()]
        [ValidateSet("Uppercase", "Lowercase", "Capitalize")]
        [String]
        $Format
    )

    begin {
        [Hashtable]$BGN_PCGN_1947 = @{
            "А" = "A"
            "Б" = "B"
            "В" = "V"
            "Г" = "G"
            "Д" = "D"
            "Е" = "E"
            "Ё" = "E"
            "Ж" = "ZH"
            "З" = "Z"
            "И" = "I"
            "Й" = "Y"
            "К" = "K"
            "Л" = "L"
            "М" = "M"
            "Н" = "N"
            "О" = "O"
            "П" = "P"
            "Р" = "R"
            "С" = "S"
            "Т" = "T"
            "У" = "U"
            "Ф" = "F"
            "Х" = "KH"
            "Ц" = "TS"
            "Ч" = "CH"
            "Ш" = "SH"
            "Щ" = "SHCH"
            "Ь" = ""
            "Ы" = "Y"
            "Ъ" = ""
            "Э" = "E"
            "Ю" = "YU"
            "Я" = "YA"
            "ЬЕ" = "YE"
        }

        [Hashtable]$GOST_R_52535_1_2006 = @{
            "А" = "A"
            "Б" = "B"
            "В" = "V"
            "Г" = "G"
            "Д" = "D"
            "Е" = "E"
            "Ё" = "E"
            "Ж" = "ZH"
            "З" = "Z"
            "И" = "I"
            "Й" = "I"
            "К" = "K"
            "Л" = "L"
            "М" = "M"
            "Н" = "N"
            "О" = "O"
            "П" = "P"
            "Р" = "R"
            "С" = "S"
            "Т" = "T"
            "У" = "U"
            "Ф" = "F"
            "Х" = "KH"
            "Ц" = "TC"
            "Ч" = "CH"
            "Ш" = "SH"
            "Щ" = "SHCH"
            "Ь" = ""
            "Ы" = "Y"
            "Ъ" = ""
            "Э" = "E"
            "Ю" = "IU"
            "Я" = "IA"
            "ЬЕ" = "E"
        }

        Switch($Standard) {
            "bgn-pcgn-1947" {
                [Hashtable]$SelectedStandardSet = $BGN_PCGN_1947
            }
            "gost-r-52535.1-2006" {
                [Hashtable]$SelectedStandardSet = $GOST_R_52535_1_2006
            }
        }
    }

    process {
        [Array]$String = $String.Split(" ")
        [Array]$NewString, [Array]$NewWordArray, [Array]$StringCommit = @()

        foreach ($Word in $String) {
            [Array]$NewWordArray = @()
            [String]$WordCommit = ""

            foreach ($Char in $Word.ToCharArray()) {
                if (($Char -eq "Е") -and ($Previous -eq "Ь")) {
                    if ($Char.ToString() -ceq $Char.ToString().ToUpper()) {
                        $NewWordArray += $SelectedStandardSet["ЬЕ"]
                    }
                    else {
                        $NewWordArray += $SelectedStandardSet["ЬЕ"].ToLower()
                    }
                }
                else {
                    if ($Char.ToString() -ceq $Char.ToString().ToUpper()) {
                        $NewWordArray += $SelectedStandardSet[$Char.ToString()]
                    }
                    else {
                        $NewWordArray += $SelectedStandardSet[$Char.ToString()].ToLower()
                    }
                }
                [String]$Previous = $Char
            }
            $WordCommit = $NewWordArray -join ""
            $StringCommit += $WordCommit
        }

        $Result = $StringCommit -join " "

        switch($Format) {
            "Uppercase" {
                $Result = $Result.ToUpper()
            }
            "Lowercase" {
                $Result = $Result.ToLower()
            }
            "Capitalize" {
                $Result = (Get-Culture).TextInfo.ToTitleCase($Result.ToLower())
            }
        }

        $Result
    }
}
