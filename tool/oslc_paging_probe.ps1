# One-shot diagnostic for the Work Order Print Pack pagination.
#
# Runs the released-WO query against Test2 like the app does (oslc.pageSize,
# collectioncount) and answers:
#   1. How many rows does Maximo matches-side total? (count=1 -> totalCount)
#   2. Does oslc.pageSize get honoured, and does responseInfo carry
#      nextPage/totalPages in lean mode? (full responseInfo dumped)
#   3. Can we follow the nextPage link, and how many rows come page by page?
#   4. Do the direct page-jump params (pageno / oslc.pageNo) also work?
#
# Usage:
#   .\tool\oslc_paging_probe.ps1 -Site GS
#   .\tool\oslc_paging_probe.ps1 -Site GS -Base 'https://other/maximo/api/os/'
#
# Full first-page JSON also lands in .\prod_data\paging_page1.json so the
# exact key shapes can be inspected afterwards.

param(
    [Parameter(Mandatory = $true)][string]$Site,
    [string]$Base = 'https://test2.manage.test2.iko.max-it-eam.com/maximo/api/os/'
)

$sec = Read-Host 'Paste the Test2 API key (input hidden)' -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
$key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
if ([string]::IsNullOrWhiteSpace($key)) { throw 'No key entered.' }

$h = @{ apikey = $key }
$out = Join-Path $PWD 'prod_data'
New-Item -ItemType Directory -Force $out | Out-Null

$baseUri = [Uri]$Base

function Show-Paging {
    param($Label, $Json)
    Write-Host "[$Label]"
    Write-Host ("  member rows: {0}" -f @($Json.member).Count)
    if ($m = $Json | Get-Member -Name responseInfo -ErrorAction SilentlyContinue) {
        $r = $Json.responseInfo
        Write-Host ("  responseInfo keys: {0}" -f (($r.PSObject.Properties.Name) -join ', '))
        foreach ($p in $r.PSObject.Properties) {
            $v = "$($p.Value)"
            if ($v.Length -gt 160) { $v = $v.Substring(0, 160) + '...' }
            Write-Host ("    {0} = {1}" -f $p.Name, $v)
        }
    } else {
        Write-Host '  responseInfo: NOT PRESENT in response!'
        Write-Host ("  top-level keys: {0}" -f (($Json.PSObject.Properties.Name) -join ', '))
    }
    Write-Host ''
}

function Get-OslcJson {
    param($Url)
    Write-Host "GET $Url"
    try {
        return Invoke-RestMethod -Uri $Url -Headers $h
    } catch {
        Write-Host "  HTTP failure: $($_.Exception.Message)"
        if ($_.ErrorDetails.Message) { Write-Host ($_.ErrorDetails.Message | Out-String).Substring(0, [Math]::Min(600, $_.ErrorDetails.Message.Length)) }
        return $null
    }
}

$where = 'status in ["RELEASED"] and siteid="{0}" and istask=0' -f $Site
$enc = [uri]::EscapeDataString($where)
$sel = 'wonum,parent,istask'

# 1. server-side total count for the exact where clause (no records)
$countUri = "$Base" + 'mxwo?lean=1&oslc.where=' + $enc + '&oslc.select=wonum&count=1'
Write-Host "=== 1. count=1 (exact match total for the where clause) ==="
$countJson = Get-OslcJson $countUri
if ($countJson) {
    Write-Host ("  keys: {0}" -f (($countJson.PSObject.Properties.Name) -join ', '))
    Write-Host ("  totalCount = {0}" -f $countJson.totalCount)
}
Write-Host ''

# 2. first paged page with collectioncount (like the app)
$pageUri = "$Base" + "mxwo?lean=1&oslc.where=$enc&oslc.select=$sel&oslc.pageSize=200&collectioncount=1"
Write-Host "=== 2. oslc.pageSize=200 + collectioncount=1 (first page) ==="
$page1 = Get-OslcJson $pageUri
if ($page1) {
    $page1 | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $out 'paging_page1.json') -Encoding UTF8
    Write-Host '  (full JSON saved to prod_data\paging_page1.json)'
    Show-Paging 'page 1' $page1

    $raw = @($page1.member)
    $parentEmpty = @($raw | Where-Object { -not $_.parent }).Count
    Write-Host ("  childless rows on page 1 (what the tool would show): {0}" -f $parentEmpty)
    Write-Host ''

    # 3. follow responseInfo.nextPage like the app does
    Write-Host "=== 3. following responseInfo.nextPage ==="
    $json = $page1
    $page = 1
    while ($json -and $json.responseInfo -and $json.responseInfo.nextPage) {
        $href = $json.responseInfo.nextPage
        Write-Host ("  -> next page {0}: {1}" -f ($page + 1), $href)
        $json = Get-OslcJson $href
        if ($json) {
            $page++
            Show-Paging "page $page" $json
            $raw += @($json.member)
        }
    }
    if ($json -and (-not ($json.responseInfo -and $json.responseInfo.nextPage))) {
        Write-Host ("  no nextPage after page {0} - walk complete, {1} raw rows total" -f $page, $raw.Count)
        $filterEmpty = @($raw | Where-Object { -not $_.parent }).Count
        Write-Host ("  childless rows across all pages: {0}" -f $filterEmpty)
    }
    Write-Host ''

    # 4. direct page-jump params
    Write-Host "=== 4. direct jump: pageno=2 and oslc.pageNo=2 ==="
    $j1 = Get-OslcJson ("$Base" + "mxwo?lean=1&oslc.where=$enc&oslc.select=$sel&oslc.pageSize=200&pageno=2")
    if ($j1) { Show-Paging 'pageno=2' $j1 }
    $j2 = Get-OslcJson ("$Base" + "mxwo?lean=1&oslc.where=$enc&oslc.select=$sel&oslc.pageSize=200&oslc.pageNo=2")
    if ($j2) { Show-Paging 'oslc.pageNo=2' $j2 }
}

Write-Host 'Done.'
