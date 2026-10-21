# Dumps the work order tree data the Work Order Print Pack needs, as JSON
# files you can paste back / share. The API key is prompted for and never
# written anywhere.
#
# Usage:
#   .\tool\prod_wo_dump.ps1 -Wonum W25X99999 -Site GS [-Env BASEURL]
#
# Writes (to .\prod_data\):
#   parent.json  children.json  tasks.json  assets.json  plan.json

param(
    [Parameter(Mandatory = $true)][string]$Wonum,
    [Parameter(Mandatory = $true)][string]$Site,
    [string]$Base = 'https://prod.manage.prod.iko.max-it-eam.com/maximo/api/os/'
)

$sec = Read-Host 'Paste the PROD API key (input hidden)' -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
$key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
if ([string]::IsNullOrWhiteSpace($key)) { throw 'No key entered.' }

$h = @{ apikey = $key }
$Wonum = $Wonum.ToUpper()
$out = Join-Path $PWD 'prod_data'
New-Item -ItemType Directory -Force $out | Out-Null

function Get-Oslc {
    param($struct, $where, $select, $name)
    $uri = "$Base$struct" +
        "?oslc.where=$([uri]::EscapeDataString($where))" +
        "&oslc.select=$([uri]::EscapeDataString(($select -join ',')))" +
        '&lean=1'
    $res = Invoke-RestMethod -Uri $uri -Headers $h
    $res | ConvertTo-Json -Depth 40 | Set-Content (Join-Path $out "$name.json") -Encoding UTF8
    $members = @($res.member)
    Write-Host ("wrote {0}.json ({1} rows)" -f $name, $members.Count)
    return $members
}

# 1. parent header
$parentSelect = @('wonum','description','description_longdescription','status',
    'worktype','wopriority','siteid','assetnum','location','jpnum','pmnum',
    'supervisor','targstartdate','targcompdate','reportdate',
    'iko_conditions_description','estdur','schedstart','schedfinish',
    'statusdate','parent')
$parent = Get-Oslc 'mxwo' ('wonum="{0}" and siteid="{1}"' -f $Wonum, $Site) $parentSelect 'parent'

# 2. children (task WOs filtered out)
$childSelect = @('wonum','taskid','istask','description','description_longdescription',
    'status','worktype','wopriority','assetnum','location','estdur',
    'targstartdate','targcompdate','parent')
$children = Get-Oslc 'mxwo' ('parent="{0}" and siteid="{1}"' -f $Wonum, $Site) $childSelect 'children' |
    Where-Object { "$($_.istask)" -ne 'true' }

# tree = parent + children
$tree = @($Wonum) + @($children | ForEach-Object { "$($_.wonum)" })
$in = ($tree | ForEach-Object { '"' + $_ + '"' }) -join ','
Write-Host ("tree: {0} work orders ({1} children)" -f $tree.Count, $children.Count)

# 3. all task WOs of the tree
Get-Oslc 'mxwo' ("parent in [$in] and siteid=`"$Site`" and istask=1") @(
    'wonum','taskid','parent','description','description_longdescription','status') 'tasks'

# 4. asset descriptions
$assetNums = @($parent[0].assetnum) + @($children | ForEach-Object { "$($_.assetnum)" }) |
    Where-Object { $_ -and $_ -ne '' } | Select-Object -Unique
if ($assetNums.Count -gt 0) {
    $ain = ($assetNums | ForEach-Object { '"' + $_ + '"' }) -join ','
    Get-Oslc 'mxasset' ("assetnum in [$ain] and siteid=`"$Site`"") @('assetnum','description') 'assets'
}

# 5. planned labor / materials / tools / assignments for the whole tree
Get-Oslc 'ikomxwodetail' ("wonum in [$in] and siteid=`"$Site`"") @(
    'wonum','istask','wplabor','wpmaterial','wptool','assignment') 'plan'

Write-Host "`nDone - JSON files are in $out"
