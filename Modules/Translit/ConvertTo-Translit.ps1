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
    
    .PARAMETER ExcludeSpecialSymbols
        Exclude from output symbols like "Ё", "'", "`", etc.

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

        if ($String -cmatch "[A-Z,a-z,0-9]") {
            Write-Error -message "String consist non-cyrillic symbols or numbers"
            exit
        }

        if ($Standard -eq "bgn-pcgn-1947") {
            Write-Warning -message "BGN/PCGN 1947 System: Checked for validity and accuracy - February 2018`nhttps://www.gov.uk/government/publications/romanisation-systems"
        }

        [Array]$NewString, [Array]$StringCommit = @()

        foreach ($Word in [Array]$String.Split(" ")) {
            [String]$NewWord, [String]$WordCommit = ""
            foreach ($Char in $Word.ToCharArray()) {
                switch($Standard){
                    "bgn-pcgn-1947" {
                        if (($Char -eq "Е") -and `
                            (($PreviousChar -eq "А") `
                            -or ($PreviousChar -eq "Е") `
                            -or ($PreviousChar -eq "Ё") `
                            -or ($PreviousChar -eq "И") `
                            -or ($PreviousChar -eq "О") `
                            -or ($PreviousChar -eq "У") `
                            -or ($PreviousChar -eq "Ы") `
                            -or ($PreviousChar -eq "Э") `
                            -or ($PreviousChar -eq "Ю") `
                            -or ($PreviousChar -eq "Й") `
                            -or ($PreviousChar -eq "Ъ") `
                            -or ($PreviousChar -eq "Ь") `
                            )) {
                            if (CharIsUppercase($Char)) {
                                $NewWord += "YE"
                            }
                            else {
                                $NewWord += "YE".ToLower()
                            }
                        }
                        elseif (($Char -eq "Ё") -and `
                            (($PreviousChar -eq "А") `
                            -or ($PreviousChar -eq "Е") `
                            -or ($PreviousChar -eq "Ё") `
                            -or ($PreviousChar -eq "И") `
                            -or ($PreviousChar -eq "О") `
                            -or ($PreviousChar -eq "У") `
                            -or ($PreviousChar -eq "Ы") `
                            -or ($PreviousChar -eq "Э") `
                            -or ($PreviousChar -eq "Ю") `
                            -or ($PreviousChar -eq "Й") `
                            -or ($PreviousChar -eq "Ъ") `
                            -or ($PreviousChar -eq "Ь") `
                            )) {
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
                        if (($Char -eq "Ц") -and `
                            (($PreviousChar -eq "И") `
                            -or ($PreviousChar -eq "Е") `
                            -or ($PreviousChar -eq "Ы") `
                            -or ($PreviousChar -eq "Й") `
                            )) {
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
            $Result = $Result.Replace("Ё","E")
            $Result = $Result.Replace("ё","e")
            $Result = $Result.Replace("`"","")
            $Result = $Result.Replace("`'","")
            $Result = $Result.Replace("``","")
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
