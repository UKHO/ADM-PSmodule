InModuleScope $mut {

    Describe "Get-Differences" {
        Context "When setOne contains one item and setTwo is empty" {
            $setOne = @{"keyOne" = "keyOneValue"}
            $setTwo = @{}

            $toBeAdded, $toBeRemoved = Get-Differences $setOne $setTwo

            It "toBeAdded should contain one value" {
                $toBeAdded.Count | Should Be 1
            }

            It "toBeadded should contain the correct value" {
                $toBeAdded[0] | Should Be "keyOneValue"
            }

            It "toBeRemoved should contain no values" {
                $toBeRemoved.Count | Should Be 0
            }
        }

        Context "When setTwo contains one item and setOne is empty" {
            $setOne = @{}
            $setTwo = @{"keyOne" = "keyOneValue"}

            $toBeAdded, $toBeRemoved = Get-Differences $setOne $setTwo

            It "toBeAdded should contain no values" {
                $toBeAdded.Count | Should Be 0
            }

            It "toBeRemoved should contain one value" {
                $toBeRemoved.Count | Should Be 1
            }

            It "toBeRemoved should contain the correct value" {
                $toBeRemoved[0] | Should Be "keyOneValue"
            }
        }

        Context "When setOne and setTwo contain the same item" {
            $setOne = @{"keyOne" = "keyOneValue"}
            $setTwo = @{"keyOne" = "keyOneValue"}

            $toBeAdded, $toBeRemoved = Get-Differences $setOne $setTwo

            It "toBeAdded should contain no values" {
                $toBeAdded.Count | Should Be 0
            }

            It "toBeRemoved should contain no values" {
                $toBeRemoved.Count | Should Be 0
            }
        }

        Context "When setOne and setTwo contain one item but they are different" {
            $setOne = @{"keyOne" = "keyOneValue"}
            $setTwo = @{"keyTwo" = "keyTwoValue"}

            $toBeAdded, $toBeRemoved = Get-Differences $setOne $setTwo

            It "toBeAdded should contain one value" {
                $toBeAdded.Count | Should Be 1
            }

            It "toBeadded should contain the correct value" {
                $toBeAdded[0] | Should Be "keyOneValue"
            }

            It "toBeRemoved should contain the correct value" {
                $toBeRemoved[0] | Should Be "keyTwoValue"
            }

            It "toBeRemoved should contain one value" {
                $toBeRemoved.Count | Should Be 1
            }
        }

        Context "When setOne and setTwo contain one item that are the same and one item which is different" {
            $setOne = @{"keyOne" = "keyOneValue"; "keyThree" = "keyThreeValue"}
            $setTwo = @{"keyTwo" = "keyTwoValue"; "keyThree" = "keyThreeValue"}

            $toBeAdded, $toBeRemoved = Get-Differences $setOne $setTwo

            It "toBeAdded should contain one value" {
                $toBeAdded.Count | Should Be 1
            }

            It "toBeadded should contain the correct value" {
                $toBeAdded[0] | Should Be "keyOneValue"
            }

            It "toBeRemoved should contain the correct value" {
                $toBeRemoved[0] | Should Be "keyTwoValue"
            }

            It "toBeRemoved should contain one value" {
                $toBeRemoved.Count | Should Be 1
            }
        }
    }
}
