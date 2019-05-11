## Power BI API - Misc functions
## Documentation: https://docs.microsoft.com/en-us/rest/api/power-bi/
## Microsoft samples: https://github.com/Azure-Samples/powerbi-powershell

## Configuration and Init
# =====================================================

# Init variables
$filePath = "./"
$fileName = "powerBI_datasets_parameters.txt"

$groupID = "" # the ID of the group that hosts the dataset. Use "me" if this is your My Workspace
$datasetID = "" # the ID of the dataset that hosts the dataset

$parameterName = ""
$parameterNewValue = ""

$scheduleDays = @("")
$scheduleTimes = @("")
$scheduleTimeZone = ""

# Login to the PowerBi service
Login-PowerBIServiceAccount


# Get token
$headers = Get-PowerBIAccessToken


# Properly format groups path
$groupsPath = ""
if ($groupID -eq "me") {
    $groupsPath = "myorg"
} else {
    $groupsPath = "myorg/groups/$groupID"
}

## End Parameters =======================================


## Refresh a dataset
$uri = "https://api.powerbi.com/v1.0/$groupsPath/datasets/$datasetID/refreshes"
Invoke-RestMethod -Uri $uri -Headers $headers -Method POST


## Get a dataset's parameters
$uri = "https://api.powerbi.com/v1.0/$groupsPath/datasets/$datasetID/parameters"
Invoke-RestMethod -Uri $uri -Headers $headers -Method GET


## Update parameters
# Define the parameters to update
$body = @{
  "updateDetails" = @(
    @{
      "name" = $parameterName
      "newValue" = $parameterNewValue
    }
  )
}

# Convert the parameters list to a json format
$jsonPostBody = $body | ConvertTo-JSON

$uri = "https://api.powerbi.com/v1.0/$groupsPath/datasets/$datasetID/Default.UpdateParameters"
Invoke-RestMethod -Uri $uri -Headers $headers -Method POST -Body $jsonPostBody -ContentType "application/json"


## Define a refresh schedule
# Build the list of values for the new schedule
$body = @{
  "value" =
	@{
	  "days" = $scheduleDays
	  "times" = $scheduleTimes
	  "localTimeZoneId" = $scheduleTimeZone
	}
}

# Convert the list to a json format
$jsonPostBody = $body | ConvertTo-JSON

$uri = "https://api.powerbi.com/v1.0/$groupsPath/datasets/$datasetid/refreshSchedule"
Invoke-RestMethod -Uri $uri -Headers $headers -Method PATCH -Body $jsonPostBody -ContentType "application/json"


## Update parameters of a list of datasets based on a text file
# Import CSV source file
$csv = Import-Csv -path $filePath$fileName -Delimiter ";"

# For each line we retrieve the workspace's ID we want to update and the list of parameters
$csv | ForEach-Object {
	
	# Record's fields extracted
	$workspaceNameFile = $_.workspacename
	$workspaceIDFile = $_.workspaceid
	$datasetIDFile = $_.datasetid
	$parameterNameFile = $_.parameter
	$parameterValueFile = $_.value

	# Build the list of parameters and values
	$body = @{
	  "updateDetails" = @(
		@{
		  "name" = $parameterNameFile
		  "newValue" = $parameterValueFile
		}
	  )
	}
	
	# Properly format groups path
	$groupsPath = ""
	if ($workspaceIDFile -eq "me") {
		$groupsPath = "myorg"
	} else {
		$groupsPath = "myorg/groups/$workspaceid"
	}
		
	# Convert the parameters list to a json format
	$jsonPostBody = $body | ConvertTo-JSON
	
	# Build and Invoke the request
	$msg = "Update $workspaceNameFile - Parameter: $parameterNameFile - Value: $parameterValueFile"
	Write-Output $msg 
	$uri = "https://api.powerbi.com/v1.0/$groupsPath/datasets/$datasetIDFile/Default.UpdateParameters"
	Invoke-RestMethod -Uri $uri -Headers $headers -Method POST -Body $jsonPostBody -ContentType "application/json"
	
}
