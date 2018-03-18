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
        PS> ConvertTo-Translit -String "������ ϸ�� �����������" -Standard gost-r-52535.1-2006
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
                If (($Char -eq "�") -and ($Previous -eq "�")) {
                    $NewWordArray += $StandardSet["��"]
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
            "�" = "A";
            "�" = "B";
            "�" = "V";
            "�" = "G";
            "�" = "D";
            "�" = "E";
            "�" = "E";
            "�" = "ZH";
            "�" = "Z";
            "�" = "I";
            "�" = "Y";
            "�" = "K";
            "�" = "L";
            "�" = "M";
            "�" = "N";
            "�" = "O";
            "�" = "P";
            "�" = "R";
            "�" = "S";
            "�" = "T";
            "�" = "U";
            "�" = "F";
            "�" = "KH";
            "�" = "TS";
            "�" = "CH";
            "�" = "SH";
            "�" = "SHCH";
            "�" = "";
            "�" = "Y";
            "" = "";
            "�" = "E";
            "�" = "YU";
            "�" = "YA";
            "��" = "YE"
        }

    $GOST_R_52535_1_2006 = @{
            "�" = "A";
            "�" = "B";
            "�" = "V";
            "�" = "G";
            "�" = "D";
            "�" = "E";
            "�" = "E";
            "�" = "ZH";
            "�" = "Z";
            "�" = "I";
            "�" = "I";
            "�" = "K";
            "�" = "L";
            "�" = "M";
            "�" = "N";
            "�" = "O";
            "�" = "P";
            "�" = "R";
            "�" = "S";
            "�" = "T";
            "�" = "U";
            "�" = "F";
            "�" = "KH";
            "�" = "TC";
            "�" = "CH";
            "�" = "SH";
            "�" = "SHCH";
            "�" = "";
            "�" = "Y";
            "�" = "";
            "�" = "E";
            "�" = "IU";
            "�" = "IA";
            "��" = "E"
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