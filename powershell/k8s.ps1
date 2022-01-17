# login to aks cluster

az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

# get and decode a secret

kubectl get secret <<secretname>> -n <<namespace>> -o json | ConvertFrom-Json | ? data | select -ExpandProperty data | % { $_.PSObject.Properties | % { $_.Name + [System.Environment]::NewLine + [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_.Value)) + [System.Environment]::NewLine + [System.Environment]::NewLine } }