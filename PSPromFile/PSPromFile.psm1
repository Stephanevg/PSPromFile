Enum PrometheusMetricType {
    counter
    gauge
    histogram
    summary
}
Class PromFileLabel{
    [String]$name
    [string]$value

    PromFileLabel(){

    }

    PromFileLabel([String]$Name,[String]$Value){
        $this.Name = $Name
        $this.value = $Value
    }

    [String]ToString(){
        return "$($this.Name)=`"$($this.Value)`""
    }
}

Class PromFile {
    [System.Collections.Generic.List[PrometheusMetric]] $Metrics = [System.Collections.Generic.List[PrometheusMetric]]::new()
    hidden [String]$FileName
    $MetricName
    [String]$HelpText
    [PrometheusMetricType]$Type
    
    [System.IO.DirectoryInfo]$FolderPath = "C:\Program Files\windows_exporter\textfile_inputs\"

    PromFile(){
        
        $this.Metrics = [System.Collections.Generic.List[PrometheusMetric]]::new()
    }

    #Getters and setters

    [Void]SetMetricName([string]$name){
        $this.MetricName = $name
        $this.SetFileName($name)
    }

    [void]SetHelpText([string]$help){
        $this.HelpText = $help
    }

    [void]SetFileName([String]$name){
        $This.FileName = $Name + ".prom"        
    }

    [void]SetFolderPath([System.IO.DirectoryInfo]$path){
        $this.FolderPath = $path
    }

    [void]SetType([PrometheusMetricType]$type){
        $this.Type = $type
    }

    [Void]AddMetric([PrometheusMetric[]]$Metrics){
        foreach($metric in $metrics){

            $this.Metrics.Add($metric)
        }
    }


    [String]ToString(){
        $stringBuilder = [System.Text.StringBuilder]::new()
        

        #prom file has a header with the metric name and the help text
        #Can have one or more metrics of the same type in the file.
        $null = $stringBuilder.AppendLine("# HELP $($this.MetricName) $($this.HelpText)")
        $null = $stringBuilder.AppendLine("# TYPE $($this.MetricName) $($this.Type)")

        foreach($metric in $this.Metrics){
            $null = $stringBuilder.AppendLine($metric.ToString())
        }

        #Add emtpy line as prom files need to end with an empty line
        #$stringBuilder.AppendLine()

        return $stringBuilder.ToString()
    }

    [Void]WriteToFile(){
        if($this.FolderPath.Exists -eq $false){
            $this.FolderPath.Create()
        }
        $this.ToString() | Out-File -FilePath "$($this.FolderPath)\$($this.FileName)" -Encoding UTF8 -Force
    }

    
}

Class PrometheusMetric {
    [string]$metricName
    [string]$value
    [PrometheusMetricType]$Type
    [System.Collections.Generic.List[PromFileLabel]] $Labels = [System.Collections.Generic.List[PromFileLabel]]::new()


    PrometheusMetric(){
        
    }

    [Void]AddLabel([PromFileLabel[]]$Labels){
        foreach($label in $labels){

            $this.Labels.Add($Label)
        }
    }

    [void]SetMetricName([string]$name){
        $this.metricName = $name
    }

    [void]SetValue([string]$value){
        $this.value = $value
    }

    [void]SetType([PrometheusMetricType]$type){
        $this.Type = $type
    }

    [String]ToString(){
        Throw "Should be implemented by child classes"
    }

    
}
class PrometheusGauge : PrometheusMetric {
    

    PrometheusGauge([string]$name) {
        $this.metricName = $name
        $this.SetType([PrometheusMetricType]::gauge)

    }

    [Void]AddLabel([PromFileLabel[]]$Labels){
        foreach($label in $labels){

            $this.Labels.Add($Label)
        }
    }


    [string] ToString() {
        
        $FinalString = ""
        if ($this.value) {
            $FinalString = ""
            if ($this.labels) {
                $ls = $this.labels.GetEnumerator() | ForEach-Object { $_.ToString() }
                $joined = $ls -join ','
                
                $FinalString = "$($this.metricName){$($Joined)} $($this.value)"
                
            }else{
                #No labels were added
                $FinalString = "$($this.metricName) $($this.value)"
            }  

        }

        return $FinalString 
    }

}


Function Write-PromFile {
    <#
        .SYNOPSIS
            Writes a prom file to the specified folder path
            Default folder path is C:\Program Files\windows_exporter\textfile_inputs\
        .DESCRIPTION
            Writes a prom file to the specified folder path
            Default folder path is C:\Program Files\windows_exporter\textfile_inputs\
        .PARAMETER PromFile
            The prom file object to write to file
            Use New-PromFile to create a new prom file object
        .PARAMETER FolderPath
            The folder path to write the prom file to
            Default folder path is C:\Program Files\windows_exporter\textfile_inputs\
        .EXAMPLE
            $PromFile = new-promfile -MetricName "test" -HelpText "test" -Type gauge
            write-promfile -PromFile $promFile
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [PromFile]$PromFile,

        [Parameter(Mandatory=$false,Position=1)]
        [System.IO.DirectoryInfo]$FolderPath,

        [Parameter(Mandatory=$false)]
        [Switch]$PassThru

    )

    if($FolderPath){
        $promFile.SetFolderPath($FolderPath)
    }
    $promFile.WriteToFile()
    if($PassThru){
        return $promFile
    }
}

Function New-PromFile {
    <#
    .SYNOPSIS
        Creates a new prom file object
    .PARAMETER MetricName
        The name of the metric
    .PARAMETER HelpText
        The help text for the metric
    
    .PARAMETER Type
        The type of the metric
        Type can be counter, gauge, histogram or summary (Part of enum PrometheusMetricType)
    .PARAMETER FolderPath
        The folder path to write the prom file to
        Default folder path is C:\Program Files\windows_exporter\textfile_inputs\
    .OUTPUTS
        PromFile

    .EXAMPLE
        New-PromFile -MetricName "test_metric" -HelpText "This is a test metric" -Type "gauge" -FolderPath "C:\Program Files\windows_exporter\textfile_inputs\"
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$MetricName,

        [Parameter(Mandatory = $true)]
        [string]$HelpText,

        [Parameter(Mandatory = $true)]
        [PrometheusMetricType]$Type,

        [Parameter(Mandatory = $False)]
        [System.Io.DirectoryInfo]
        $FolderPath, # default to C:\Program Files\windows_exporter\textfile_inputs\

        [PrometheusMetric[]] $Metrics

    )

    $promFile = [PromFile]::new()
    $promFile.SetMetricName($MetricName)
    $promFile.SetHelpText($HelpText)
    $promFile.SetType($Type)
    if($FolderPath){
        $promFile.SetFolderPath($FolderPath)
    }

    if($Metrics){
        foreach($metric in $Metrics){
            $promFile.AddMetric($metric)
        }
    }

    return $promFile
    
}
Function New-PrometheusMetricGauge {
    [CmdletBinding()]
    Param(


        [Parameter(Mandatory = $true)]
        [ValidatePattern("^[a-zA-Z_:][a-zA-Z0-9_:]*$")]
        [string]$Name,

        [Parameter(Mandatory = $False)]
        [PromFileLabel[]]$Labels,

        [Parameter(Mandatory = $True)]
        $Value
    )

    $gauge = [PrometheusGauge]::new($Name)
    if($Labels){

        $gauge.AddLabel($Labels)
    }
    $gauge.SetValue($Value)
    return $gauge
}

Function New-PrometheusLabel {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $label = [PromFileLabel]::new($Name, $Value)
    return $label
}

