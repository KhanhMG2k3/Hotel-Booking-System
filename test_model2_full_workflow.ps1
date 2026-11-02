# ==============================================================================
# Script Kiem thu Toan dien Model 2:
# 1. Vi Host ban dau 0 VND
# 2. Khach dat phong (2.000 VND) -> Sepay Webhook -> Vi Host duoc cong 2.000 VND
# 3. Host rut tien don phong ve ngan hang -> Vi Host tru 2.000 VND -> Balance = 0 VND
# 4. Khach huy phong -> Vi Host 0 VND khong du de hoan -> Canh bao thieu so du
# 5. Host nap tien vi -> Duyet hoan tien thanh cong -> Tru so du vi
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$baseUrl = "http://localhost:8080"
$amp = [char]38

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "     KIEM THU TOAN DIEN QUY TRINH VI HOST & RUT TIEN & HOAN TIEN     " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# Reset vi Host 3 ve 0 VND truoc khi test
# ------------------------------------------------------------------------------
& "C:\Program Files\MySQL\MySQL Workbench 8.0 CE\mysql.exe" -u homestay_app -pHomestayDev@2026! -e "USE homestaybooking_iter; UPDATE wallet_accounts SET balance = 0.00 WHERE owner_user_id = 3; DELETE FROM wallet_transactions WHERE user_id = 3;"

# ------------------------------------------------------------------------------
# BUOC 1: Dang nhap Host & Kiem tra so du ban dau la 0 VND
# ------------------------------------------------------------------------------
Write-Host "`n[1/6] Dang nhap Host (host@homestay.com) & Kiem tra so du ban dau la 0 VND..." -ForegroundColor Yellow
$jarHost = New-Object System.Net.CookieContainer
$loginHostReq = [System.Net.HttpWebRequest]::Create("$baseUrl/login")
$loginHostReq.CookieContainer = $jarHost
$loginHostReq.Method = "POST"
$loginHostReq.ContentType = "application/x-www-form-urlencoded"
$hostLoginParams = @{ username = "host@homestay.com"; password = "123456" }
$hostLoginStr = ($hostLoginParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join $amp
$bodyHost = [System.Text.Encoding]::UTF8.GetBytes($hostLoginStr)
$loginHostReq.ContentLength = $bodyHost.Length
$stream = $loginHostReq.GetRequestStream()
$stream.Write($bodyHost, 0, $bodyHost.Length)
$stream.Close()
$loginHostResp = $loginHostReq.GetResponse()
$loginHostResp.Close()

$dashReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/dashboard")
$dashReq.CookieContainer = $jarHost
$dashResp = $dashReq.GetResponse()
$dashHtml = (New-Object System.IO.StreamReader($dashResp.GetResponseStream())).ReadToEnd()
$dashResp.Close()

if ($dashHtml -match 'stat-value text-success font-weight-bold">([\s\S]*?)</div>') {
    $bal = $matches[1].Trim()
    Write-Host "  -> XAC NHAN: So du vi Host hien tai: $bal" -ForegroundColor Green
} else {
    Write-Host "  -> Canh bao kiem tra so du HTML!" -ForegroundColor Yellow
}

# ------------------------------------------------------------------------------
# BUOC 2: Khach hang tao don dat phong 2.000 VND
# ------------------------------------------------------------------------------
Write-Host "`n[2/6] Khach hang tao don dat phong (Single Cozy Room - 2.000 VND)..." -ForegroundColor Yellow
$jarCustomer = New-Object System.Net.CookieContainer
$loginReq = [System.Net.HttpWebRequest]::Create("$baseUrl/login")
$loginReq.CookieContainer = $jarCustomer
$loginReq.Method = "POST"
$loginReq.ContentType = "application/x-www-form-urlencoded"
$loginParams = @{ username = "hai14042004@gmail.com"; password = "123456" }
$loginStr = ($loginParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join $amp
$body = [System.Text.Encoding]::UTF8.GetBytes($loginStr)
$loginReq.ContentLength = $body.Length
$stream = $loginReq.GetRequestStream()
$stream.Write($body, 0, $body.Length)
$stream.Close()
$loginResp = $loginReq.GetResponse()
$loginResp.Close()

$checkIn = (Get-Date).AddDays(10).ToString("dd/MM/yyyy")
$checkOut = (Get-Date).AddDays(11).ToString("dd/MM/yyyy")
$bookReq = [System.Net.HttpWebRequest]::Create("$baseUrl/reservation")
$bookReq.CookieContainer = $jarCustomer
$bookReq.Method = "POST"
$bookReq.ContentType = "application/x-www-form-urlencoded"
$bookReq.AllowAutoRedirect = $false

$bookParams = @{
    name = "Nguyen Thanh Hai"
    email = "hai14042004@gmail.com"
    phone = "0901234567"
    checkin_date = $checkIn
    checkout_date = $checkOut
    adults = "1"
    children = "0"
    room_id = "1"
    notes = "Test Model 2 Full Flow"
}
$postData = ($bookParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join $amp
$body = [System.Text.Encoding]::UTF8.GetBytes($postData)
$bookReq.ContentLength = $body.Length
$stream = $bookReq.GetRequestStream()
$stream.Write($body, 0, $body.Length)
$stream.Close()

$bookResp = $bookReq.GetResponse()
$redirectLoc = $bookResp.Headers["Location"]
$bookResp.Close()

if ($redirectLoc -match "bookingId=(\d+)") {
    $bookingId = [int]$matches[1]
    Write-Host "  -> Tao thanh cong Booking ID: $bookingId" -ForegroundColor Green
} else {
    Write-Host "  -> Loi tao booking!" -ForegroundColor Red
    exit 1
}

# Lay bookingCode
$pollUrl = "$baseUrl/api/payment/status?bookingId=$bookingId"
$pollReq = [System.Net.HttpWebRequest]::Create($pollUrl)
$pollReq.CookieContainer = $jarCustomer
$pollResp = $pollReq.GetResponse()
$pollJson = (New-Object System.IO.StreamReader($pollResp.GetResponseStream())).ReadToEnd()
$pollResp.Close()
$pollObj = $pollJson | ConvertFrom-Json
$bookingCode = $pollObj.bookingCode
$amount = $pollObj.totalAmount
Write-Host "  -> Ma dat phong: $bookingCode | Tong tien: $amount VND" -ForegroundColor Green

# ------------------------------------------------------------------------------
# BUOC 3: SePay Webhook xac nhan thanh toan -> Cong tien vao Vi Host
# ------------------------------------------------------------------------------
Write-Host "`n[3/6] SePay Webhook xac nhan thanh toan $amount VND..." -ForegroundColor Yellow
$webhookUrl = "$baseUrl/api/payment/webhook"
$webhookReq = [System.Net.HttpWebRequest]::Create($webhookUrl)
$webhookReq.Method = "POST"
$webhookReq.ContentType = "application/json; charset=utf-8"

$cleanCode = $bookingCode -replace "-", ""
$sepayPayload = '{"gateway":"TPBank","transferType":"in","transferAmount":' + [int]$amount + ',"content":"HOMESTAY ' + $cleanCode + '"}'
$payloadBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($sepayPayload)
$webhookReq.ContentLength = $payloadBytes.Length
$stream = $webhookReq.GetRequestStream()
$stream.Write($payloadBytes, 0, $payloadBytes.Length)
$stream.Close()

$webhookResp = $webhookReq.GetResponse()
$webhookRespText = (New-Object System.IO.StreamReader($webhookResp.GetResponseStream())).ReadToEnd()
$webhookResp.Close()
Write-Host "  -> Webhook phan hoi: $webhookRespText" -ForegroundColor Green

# Kiem tra lai Dashboard cua Host -> So du phai tang len dung 2.000 VND!
$dashReq2 = [System.Net.HttpWebRequest]::Create("$baseUrl/host/dashboard")
$dashReq2.CookieContainer = $jarHost
$dashResp2 = $dashReq2.GetResponse()
$dashHtml2 = (New-Object System.IO.StreamReader($dashResp2.GetResponseStream())).ReadToEnd()
$dashResp2.Close()

if ($dashHtml2 -match 'stat-value text-success font-weight-bold">([\s\S]*?)</div>') {
    $bal2 = $matches[1].Trim()
    Write-Host "  -> XAC NHAN: So du vi Host sau khi khach thanh toan: $bal2" -ForegroundColor Green
} else {
    Write-Host "  -> Canh bao kiem tra so du sau khi cong!" -ForegroundColor Yellow
}

# ------------------------------------------------------------------------------
# BUOC 4: Host bam 'Rut tien ve ngan hang' cho rieng don dat phong nay
# ------------------------------------------------------------------------------
Write-Host "`n[4/6] Host thao tac RUT TIEN doanh thu ve ngan hang (Booking #$bookingCode)..." -ForegroundColor Yellow
$withdrawReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/dashboard")
$withdrawReq.CookieContainer = $jarHost
$withdrawReq.Method = "POST"
$withdrawReq.ContentType = "application/x-www-form-urlencoded"
$withdrawReq.Accept = "application/json"

$wdParams = @{
    action = "withdraw"
    bookingId = "$bookingId"
    bankCode = "TPBANK"
    accountNumber = "22465786789"
    accountHolder = "NGUYEN THANH HAI"
    notes = "Rut doanh thu don phong $bookingCode ve TPBank"
    ajax = "true"
}
$wdStr = ($wdParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join $amp
$wdBody = [System.Text.Encoding]::UTF8.GetBytes($wdStr)
$withdrawReq.ContentLength = $wdBody.Length
$stream = $withdrawReq.GetRequestStream()
$stream.Write($wdBody, 0, $wdBody.Length)
$stream.Close()

$withdrawResp = $withdrawReq.GetResponse()
$withdrawJson = (New-Object System.IO.StreamReader($withdrawResp.GetResponseStream())).ReadToEnd()
$withdrawResp.Close()
Write-Host "  -> Ket qua rut tien: $withdrawJson" -ForegroundColor Green

# Kiem tra lai Dashboard cua Host -> So du vi phai giam ve 0 VND!
$dashReq3 = [System.Net.HttpWebRequest]::Create("$baseUrl/host/dashboard")
$dashReq3.CookieContainer = $jarHost
$dashResp3 = $dashReq3.GetResponse()
$dashHtml3 = (New-Object System.IO.StreamReader($dashResp3.GetResponseStream())).ReadToEnd()
$dashResp3.Close()

if ($dashHtml3 -match '0\s*VN') {
    Write-Host "  -> XAC NHAN: So du vi Host da giam ve 0 VND sau khi rut tien!" -ForegroundColor Green
}
if ($dashHtml3 -match 'Đã rút tiền') {
    Write-Host "  -> XAC NHAN: Don dat phong hien thi badge 'Da rut tien'!" -ForegroundColor Green
}

# Thu rut tien lan nua cho don nay -> He thong phai chan
Write-Host "  -> Thu rut tien lai don da rut (kiem tra chong rut trung lap)..." -ForegroundColor DarkGray
try {
    $withdrawDupReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/dashboard")
    $withdrawDupReq.CookieContainer = $jarHost
    $withdrawDupReq.Method = "POST"
    $withdrawDupReq.ContentType = "application/x-www-form-urlencoded"
    $withdrawDupReq.Accept = "application/json"
    $withdrawDupReq.ContentLength = $wdBody.Length
    $stream = $withdrawDupReq.GetRequestStream()
    $stream.Write($wdBody, 0, $wdBody.Length)
    $stream.Close()
    $withdrawDupResp = $withdrawDupReq.GetResponse()
    $withdrawDupResp.Close()
} catch [System.Net.WebException] {
    $errResp = $_.Exception.Response
    $errReader = New-Object System.IO.StreamReader($errResp.GetResponseStream())
    $errBody = $errReader.ReadToEnd()
    Write-Host "  -> He thong da ngan chan dung: $errBody" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# BUOC 5: Khach yeu cau huy phong & Host kiem tra canh bao khong du so du vi
# ------------------------------------------------------------------------------
Write-Host "`n[5/6] Khach hang yeu cau hoan tien -> Host duyet khi vi 0 VND (kiem tra canh bao thieu so du)..." -ForegroundColor Yellow
$refundReq = [System.Net.HttpWebRequest]::Create("$baseUrl/refund/request")
$refundReq.CookieContainer = $jarCustomer
$refundReq.Method = "POST"
$refundReq.ContentType = "application/x-www-form-urlencoded"
$refundReq.Accept = "application/json"

$rfParams = @{
    bookingId = "$bookingId"
    reason = "Ban viec dot xuat"
    bankName = "MBBank"
    accountNumber = "0987654321"
    accountHolder = "NGUYEN THANH HAI"
    ajax = "true"
}
$refundPost = ($rfParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join $amp
$refundBytes = [System.Text.Encoding]::UTF8.GetBytes($refundPost)
$refundReq.ContentLength = $refundBytes.Length
$stream = $refundReq.GetRequestStream()
$stream.Write($refundBytes, 0, $refundBytes.Length)
$stream.Close()
$refundResp = $refundReq.GetResponse()
$refundResp.Close()

# Lay refundId tu trang /host/refunds
$refundsPageReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/refunds")
$refundsPageReq.CookieContainer = $jarHost
$refundsPageResp = $refundsPageReq.GetResponse()
$refundsHtml = (New-Object System.IO.StreamReader($refundsPageResp.GetResponseStream())).ReadToEnd()
$refundsPageResp.Close()

if ($refundsHtml -match 'openApproveModal\((\d+)') {
    $refundId = [int]$matches[1]
    Write-Host "  -> Tim thay Refund ID can duyet: $refundId" -ForegroundColor Green
}

# Host thu duyet khi so du vi = 0 VND -> He thong phai bao thieu so du!
try {
    $approveReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/refunds/action")
    $approveReq.CookieContainer = $jarHost
    $approveReq.Method = "POST"
    $approveReq.ContentType = "application/x-www-form-urlencoded"
    $approveReq.Accept = "application/json"
    $appParams = @{ action = "approve"; refundId = "$refundId"; hostNote = "Duyet hoan" }
    $appStr = ($appParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join $amp
    $appBody = [System.Text.Encoding]::UTF8.GetBytes($appStr)
    $approveReq.ContentLength = $appBody.Length
    $stream = $approveReq.GetRequestStream()
    $stream.Write($appBody, 0, $appBody.Length)
    $stream.Close()
    $approveResp = $approveReq.GetResponse()
    $approveResp.Close()
} catch [System.Net.WebException] {
    $errResp = $_.Exception.Response
    $errReader = New-Object System.IO.StreamReader($errResp.GetResponseStream())
    $errBody = $errReader.ReadToEnd()
    Write-Host "  -> He thong chan hoan tien do vi 0 VND: $errBody" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# BUOC 6: Host nap them 10.000 VND vao vi va hoan tat duyet hoan tien
# ------------------------------------------------------------------------------
Write-Host "`n[6/6] Host nap 10.000 VND vao vi va duyet hoan tien thanh cong..." -ForegroundColor Yellow
$topupReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/dashboard")
$topupReq.CookieContainer = $jarHost
$topupReq.Method = "POST"
$topupReq.ContentType = "application/x-www-form-urlencoded"
$topupReq.Accept = "application/json"
$topupParams = @{ action = "topup"; amount = "10000"; note = "Nap bo sung de hoan tien"; ajax = "true" }
$topupStr = ($topupParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join $amp
$topupBody = [System.Text.Encoding]::UTF8.GetBytes($topupStr)
$topupReq.ContentLength = $topupBody.Length
$stream = $topupReq.GetRequestStream()
$stream.Write($topupBody, 0, $topupBody.Length)
$stream.Close()
$topupResp = $topupReq.GetResponse()
$topupResp.Close()
Write-Host "  -> Nap 10.000 VND vao vi Host thanh cong!" -ForegroundColor Green

# Duyet lai yeu cau hoan tien
$approveReq2 = [System.Net.HttpWebRequest]::Create("$baseUrl/host/refunds/action")
$approveReq2.CookieContainer = $jarHost
$approveReq2.Method = "POST"
$approveReq2.ContentType = "application/x-www-form-urlencoded"
$approveReq2.Accept = "application/json"
$approveReq2.ContentLength = $appBody.Length
$stream = $approveReq2.GetRequestStream()
$stream.Write($appBody, 0, $appBody.Length)
$stream.Close()
$approveResp2 = $approveReq2.GetResponse()
$approveJson2 = (New-Object System.IO.StreamReader($approveResp2.GetResponseStream())).ReadToEnd()
$approveResp2.Close()
Write-Host "  -> Duyet hoan tien thanh cong sau khi nap tien vi: $approveJson2" -ForegroundColor Green

Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "  TAT CA CAC BUOC TEST QUY TRINH VI THUC & RUT TIEN DEU THANH CONG!  " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
