#PowerShell
#Requires -Version 3.0


function ConvertTo-Translit {
    <#
    .SYNOPSIS
        Function for transliteration russian-english with standards and rules.

    .DESCRIPTION
        Function for transliteration russian-english with standards and rules.
        .

    .PARAMETER String
        Input string for transliteration.

    .PARAMETER Standard
        Standard name for transliteration.

    .PARAMETER Format
        Format for output, "as is" by default.
    
    .PARAMETER ExcludeSpecialSymbols
        Exclude from output symbols like '", "`", etc.

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
    [OutputType([String])]
    Param(
        [Parameter(Mandatory,
        ValueFromPipeline,
        HelpMessage = "Enter string for transliteration")]
        [String]
        $String,

        [Parameter()]
        [ValidateSet("bgn-pcgn-1947", "gost-r-52535.1-2006", "gost-7.79-2000")]
        [String]
        $Standard = "bgn-pcgn-1947",

        [Parameter()]
        [ValidateSet("Original", "Uppercase", "Lowercase", "Capitalize")]
        [String]
        $Format = "Original",

        [Parameter()]
        [Bool]
        $ExcludeSpecialSymbols = $false
    )

    begin {
        [Hashtable]$BGN_PCGN_1947 = @{
            "А" = "A"
            "Б" = "B"
            "В" = "V"
            "Г" = "G"
            "Д" = "D"
            "Е" = "E"
            "Ё" = "Ё"
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
            "Ь" = "`'"
            "Ы" = "Y"
            "Ъ" = "`""
            "Э" = "E"
            "Ю" = "YU"
            "Я" = "YA"
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
        }

        [Hashtable]$GOST_7_79_2000 = @{
            "А" = "A"
            "Б" = "B"
            "В" = "V"
            "Г" = "G"
            "Д" = "D"
            "Е" = "E"
            "Ё" = "YO"
            "Ж" = "ZH"
            "З" = "Z"
            "И" = "I"
            "Й" = "J"
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
            "Х" = "X"
            "Ц" = "CZ"
            "Ч" = "CH"
            "Ш" = "SH"
            "Щ" = "SHH"
            "Ь" = "`'"
            "Ы" = "Y`'"
            "Ъ" = "`""
            "Э" = "E`'"
            "Ю" = "YU"
            "Я" = "YA"
        }
    }

    process {
        function CharIsUppercase() {
            ($args[0].ToString() -ceq $args[0].ToString().ToUpper())
        }

        if ($String -cmatch "[A-Za-z0-9]") {
            Write-Error -message "String consist non-cyrillic symbols or numbers"
            Return "String consist non-cyrillic symbols or numbers"
        }

        if ($Standard -eq "bgn-pcgn-1947") {
            Write-Verbose -message "BGN/PCGN 1947 System: Checked for validity and accuracy - February 2018`nhttps://www.gov.uk/government/publications/romanisation-systems"
        }

        [Array]$NewString, [Array]$StringCommit = @()

        foreach ($Word in [Array]$String.Split(" ")) {
            [String]$NewWord, [String]$WordCommit = ""
            foreach ($Char in $Word.ToCharArray()) {
                switch($Standard){
                    "bgn-pcgn-1947" {
                        if (($Char -eq "Е") -and (($PreviousChar -match "А|Е|Ё|И|О|У|Ы|Э|Ю|Й|Ъ|Ь"))) {
                            if (CharIsUppercase($Char)) {
                                $NewWord += "YE"
                            }
                            else {
                                $NewWord += "YE".ToLower()
                            }
                        }
                        elseif (($Char -eq "Ё") -and (($PreviousChar -match "А|Е|Ё|И|О|У|Ы|Э|Ю|Й|Ъ|Ь"))) {
                            if (CharIsUppercase($Char)) {
                                $NewWord += "YЁ"
                            }
                            else {
                                $NewWord += "YЁ".ToLower()
                            }
                        }
                        else {
                            if (CharIsUppercase($Char)) {
                                $NewWord += $BGN_PCGN_1947[$Char.ToString()]
                            }
                            else {
                                $NewWord += $BGN_PCGN_1947[$Char.ToString()].ToLower()
                            }
                        }
                        $PreviousChar = $Char
                    }
                    "gost-r-52535.1-2006" {
                        if (CharIsUppercase($Char)) {
                            $NewWord += $GOST_R_52535_1_2006[$Char.ToString()]
                        }
                        else {
                            $NewWord += $GOST_R_52535_1_2006[$Char.ToString()].ToLower()
                        }
                    }
                    "gost-7.79-2000" {
                        if (($Char -eq "Ц") -and (($PreviousChar -match "И|Е|Ы|Й"))) {
                            if (CharIsUppercase($Char)) {
                                $NewWord += "C"
                            }
                            else {
                                $NewWord += "C".ToLower()
                            }
                        }
                        else {
                            if (CharIsUppercase($Char)) {
                                $NewWord += $GOST_7_79_2000[$Char.ToString()]
                            }
                            else {
                                $NewWord += $GOST_7_79_2000[$Char.ToString()].ToLower()
                            }
                        }
                        $PreviousChar = $Char
                    }
                }
            }

            $PreviousChar = ""
            $WordCommit = $NewWord
            $StringCommit += $WordCommit

        }

        $Result = $StringCommit -join " "

        if ($ExcludeSpecialSymbols) {
            $Result = $Result -replace "([`"`'``])","" -replace "([Ё])","E" -replace "([ё])","e"
        }

        switch($Format) {
            "Original" {
                break
            }
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
