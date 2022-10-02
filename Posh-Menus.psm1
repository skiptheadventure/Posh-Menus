function Invoke-Menu {
    <#
    .SYNOPSIS
        Generates a multi-choice, text-based menu with selection validation.
    .DESCRIPTION
        This function gives an easy way for developers to include multi-choice menus in their interactive scripts. The function
        includes validation to ensure that the select option is a valid selection.
    .EXAMPLE
        Invoke-Menu -Items "Item 1","Item 2","Item 3"
            1: Item 1
            2: Item 2
            3: Item 3
            0: quit
            Please select an option from the list: 1

        The above would return the value "Item 1".

    .EXAMPLE
        Invoke-Menu -Items "Item 1","Item 2","Item 3"
            1: Item 1
            2: Item 2
            3: Item 3
            0: quit
            Please select an option from the list: 0

        The above would return the value "False".
    #>
    Param (
		[Parameter(ValueFromPipeline = $true)]
        [array]$Items
    )

	begin {
		$i = 1
		$MenuOptions = [ordered]@{}
		$Menu = @()
	}
	process{
		foreach ($Item in $Items) {
			$MenuOptions.Add($i,$Item)
			$i++
		}
	}
	end {
		foreach ($MenuOption in $MenuOptions.Keys) {
			$Line = [string]($MenuOption) + ": " + [string]($MenuOptions.$MenuOption)
			$Menu += $Line
		}

		$Menu += "0: quit"

		While($true) {
			Clear-Host
			$Menu | Write-Host
			
			try {
				[int]$SelectedOption = Read-Host -Prompt "Please select an option from the list"

				if ($SelectedOption -eq '0') { 
					$Selection = $false
					break
				} elseif ($MenuOptions.Keys -contains $SelectedOption) {
					$Selection = $MenuOptions.$SelectedOption
					break
				} else {
					throw
				}
			} catch {
				Write-Warning -Message "That is not a valid selection. Make sure you are only entering a number. Please try again."
				pause
				continue
			}
		}

		return $Selection
	}
}
function Read-Prompt {
    <#
    .SYNOPSIS
        Simple function to display a Yes / No prompt.
    .DESCRIPTION
        This is simple function that takes a question as input and displays a yes / no prompt on the console. It returns true
        or false based on the user response. The default response is ture but setting the switch DefaultNo will change the
        default reponse to false.
    .NOTES
        The function changes all responses to lower case before evaluating. It will accept yes or y as true responses and no or n
        as false responses. Any other responses will trigger the default response.
    .EXAMPLE
        Read-Prompt -Prompt "Is your answer to this question yes or no?"
            Is your answer to this question yes or no? [YES/no]: y

        This will return true.

    .EXAMPLE
        Read-Prompt -Prompt "Is your answer to this question yes or no?" -DefaultNo
            Is your answer to this question yes or no? [yes/NO]: 

        With no reponse from the user, this will return false.
    #>
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Prompt,
		[Parameter()]
		[switch]
		$DefaultNo
	)

	switch ($PSBoundParameters.ContainsKey('DefaultNo')){
		$true {
			$yesno = "[yes/NO]"
			$DefaultReturn = $false
		}
		$false {
			$yesno = "[YES/no]"
			$DefaultReturn = $true
		}
	}

	$Prompt = "$($Prompt) $($yesno)"

	while ($true) {
		try {
			[string]$Decision = Read-Host -Prompt $Prompt

			switch -Regex ($($Decision.ToLower())) {
				"yes|y{1}" {
					return $true
				}
				"no|n{1}" {
					return $false
				}
				default {
					return $DefaultReturn
				}
			}
		} catch {
			return $DefaultReturn
		}
	}
}