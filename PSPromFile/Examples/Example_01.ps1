import-module PSPromFile -Force

#Create label
$Label = New-PrometheusLabel -Name "PackageName" -Value "MyWoopyPackage"

#Create metric
$Metric = New-PrometheusMetricGauge -Name "district_custom_compliance" -Value 98 -Label $Label

#Create promfile
$Promfile = New-PromFile -MetricName "district_compliance" -HelpText "Defines compliancy of some sort" -Type Gauge -metrics $Metric

#Writing promfile to disk
Write-PromFile -PromFile $Promfile -FolderPath "C:\Export\"