# PSPromFile

`PsPromFile` is a cross-platform implementation to generate Prometheus .prom files in the
 the prometheus [exposition format](https://prometheus.io/docs/instrumenting/exposition_formats/).

The following metrics are currently supported 
- gauge

# Output format example

PSPromFile allows to generate .prom files as the one below

```
# HELP district_compliance Defines compliancy of some sort
# TYPE district_compliance gauge
district_custom_compliance{PackageName="MyWoopyPackage"} 98

```

To generate the file above, use the following snippet

```powershell
import-module PSPromFile -Force

#Create label
$Label = New-PrometheusLabel -Name "PackageName" -Value "MyWoopyPackage"

#Create metric
$Metric = New-PrometheusMetricGauge -Name "district_custom_compliance" -Value 98 -Label $Label

#Create promfile
$Promfile = New-PromFile -MetricName "district_compliance" -HelpText "Defines compliancy of some sort" -Type Gauge -metrics $Metric

#Writing promfile to disk in C:\Export\
Write-PromFile -PromFile $Promfile -FolderPath "C:\Export\"

```

Read the examples below to learn in more details how to use `pspromfile`


# installation

To install, simply use the command below

```powershell

install-module PsPromFile

```

To start using the module, import the module  as below

```powershell

import-module PsPromFile

```


# Examples

Below are a few examples of how metrics can be generated


## Create a simple .prom file

In order to create a new .prom file use `new-promFile`

```powershell


New-PromFile -MetricName "district_compliance" -HelpText "Defines some compliancy" -Type Gauge 

<#
Metrics    : {}
MetricName : district_compliance
HelpText   : Defines some compliancy
Type       : gauge
FolderPath : C:\Program Files\windows_exporter\textfile_inputs\
#>



```

Notice that the default export folder path is 'C:\Program Files\windows_exporter\textfile_inputs\'.

If you would like to export your `.prom` files to `C:\MyExportFolder\` do as follows

```powershell

$Promfile = New-PromFile -MetricName "district_compliance" -HelpText "Defines compliancy of some sort" -Type Gauge  -FolderPath "C:\MyExportFolder\"

```


# Metrics

To create a simple metric, use the following example

```powershell

New-PrometheusMetricGauge -Name "district_custom_compliance" -Value 98

<#
metricName                 value  Type Labels
----------                 -----  ---- ------
district_custom_compliance 98    gauge {}
#>

```

# Labels

In order create a label for your metrics, use `New-PrometheusLabel` 

```powershell

New-PrometheusLabel -Name "PackageName" -Value "MyWoopyPackage"

<#
name        value
----        -----
PackageName MyWoopyPackage
#>

```

Add a label to your metric

```powershell

$Label = New-PrometheusLabel -Name "PackageName" -Value "MyWoopyPackage"
New-PrometheusMetricGauge -Name "district_custom_compliance" -Value 98 -Label $Label

<#
metricName                 value  Type Labels
----------                 -----  ---- ------
district_custom_compliance 98    gauge {PackageName="MyWoopyPackage"}
#>

```

Add a the metric to your .prom file

```powershell

#Create a label
$Label = New-PrometheusLabel -Name "PackageName" -Value "MyWoopyPackage"

#Create a metric and add the label
$Metric = New-PrometheusMetricGauge -Name "district_custom_compliance" -Value 98 -Label $Label

#create a promfile and add the metric to it
New-PromFile -MetricName "district_compliance" -HelpText "Defines compliancy of some sort" -Type Gauge -metrics $Metric

<#
Metrics    : {district_custom_compliance{PackageName="MyWoopyPackage"} 98}
MetricName : district_compliance
HelpText   : Defines compliancy of some sort
Type       : gauge
FolderPath : C:\Program Files\windows_exporter\textfile_inputs\
#>

```

Write the metric to disk

```powershell

#Create the promFile Object
$PromFile = New-PromFile -MetricName "district_compliance" -HelpText "Defines compliancy of some sort" -Type Gauge -metrics $Metric

#Write the promFile object to disk to an alternate location
$ExportPath = "C:\MyExportFolder"
Write-PromFile -PromFile $promFile -FolderPath $ExportPath 

```

# prometheus documentation

The different metric types are documented [here](https://prometheus.io/docs/concepts/metric_types/)