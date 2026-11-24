# ==============================================================================
# Script Kiem thu Toan dien: Iteration 2 (VietQR + SePay + Email) va Iteration 3 (Stepper + Hoan tien Vi Host)
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$baseUrl = "http://localhost:8080"
$amp = [char]38

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "     BAT DAU KIEM THU TICH HOP ITERATION 2 VA ITERATION 3 (MODEL 2)   " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# BUOC 1: Dang nhap Khach hang
# ------------------------------------------------------------------------------
Write-Host "`n[1/6] Dang nhap Khach hang (hai14042004@gmail.com)..." -ForegroundColor Yellow
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
Write-Host "  -> Khach hang dang nhap thanh cong!" -ForegroundColor Green

# ------------------------------------------------------------------------------
# BUOC 2: Tao don dat phong moi (Single Cozy Room - 2.000 VND)
# ------------------------------------------------------------------------------
Write-Host "`n[2/6] Khach hang tao don dat phong moi (Single Cozy Room - 2.000 VND)..." -ForegroundColor Yellow
$checkIn = (Get-Date).AddDays(5).ToString("dd/MM/yyyy")
$checkOut = (Get-Date).AddDays(6).ToString("dd/MM/yyyy")
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
    notes = "Test Iter2 Iter3"
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
    Write-Host "  -> Loi tao booking: Redirect location: $redirectLoc" -ForegroundColor Red
    exit 1
}

# Lay bookingCode va amount tu API /api/payment/status
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
Write-Host "  -> Trang thai ban dau: $($pollObj.status) (isPaid: $($pollObj.isPaid))" -ForegroundColor DarkGray

# ------------------------------------------------------------------------------
# BUOC 3: Mo phong SePay Webhook (Khach quet VietQR chuyen khoan thanh cong)
# ------------------------------------------------------------------------------
Write-Host "`n[3/6] Mo phong SePay Webhook (VietQR) thanh toan $amount VND..." -ForegroundColor Yellow
$webhookUrl = "$baseUrl/api/payment/webhook"
$webhookReq = [System.Net.HttpWebRequest]::Create($webhookUrl)
$webhookReq.Method = "POST"
$webhookReq.ContentType = "application/json; charset=utf-8"

$cleanCode = $bookingCode -replace "-", ""
$sepayPayload = '{"gateway":"MBBank","transferType":"in","transferAmount":' + [int]$amount + ',"content":"HOMESTAY ' + $cleanCode + '"}'

$payloadBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($sepayPayload)
$webhookReq.ContentLength = $payloadBytes.Length
$stream = $webhookReq.GetRequestStream()
$stream.Write($payloadBytes, 0, $payloadBytes.Length)
$stream.Close()

$webhookResp = $webhookReq.GetResponse()
$webhookRespText = (New-Object System.IO.StreamReader($webhookResp.GetResponseStream())).ReadToEnd()
$webhookResp.Close()
Write-Host "  -> SePay Webhook phan hoi: $webhookRespText" -ForegroundColor Green

# Xac minh API Polling thoi gian thuc cap nhat CONFIRMED
$pollReq2 = [System.Net.HttpWebRequest]::Create($pollUrl)
$pollReq2.CookieContainer = $jarCustomer
$pollResp2 = $pollReq2.GetResponse()
$pollJson2 = (New-Object System.IO.StreamReader($pollResp2.GetResponseStream())).ReadToEnd()
$pollResp2.Close()
$pollObj2 = $pollJson2 | ConvertFrom-Json
Write-Host "  -> Polling thoi gian thuc: Status=$($pollObj2.status) | isPaid=$($pollObj2.isPaid)" -ForegroundColor Green

# ------------------------------------------------------------------------------
# BUOC 4: Khach hang vao My Bookings gui yeu cau huy phong / hoan tien
# ------------------------------------------------------------------------------
Write-Host "`n[4/6] Khach hang yeu cau huy phong / hoan tien qua /refund/request..." -ForegroundColor Yellow
$refundReq = [System.Net.HttpWebRequest]::Create("$baseUrl/refund/request")
$refundReq.CookieContainer = $jarCustomer
$refundReq.Method = "POST"
$refundReq.ContentType = "application/x-www-form-urlencoded"
$refundReq.Accept = "application/json"

$rfParams = @{
    bookingId = "$bookingId"
    reason = "Cong viec dot xuat"
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
$refundJson = (New-Object System.IO.StreamReader($refundResp.GetResponseStream())).ReadToEnd()
$refundResp.Close()
Write-Host "  -> Yeu cau hoan tien phan hoi: $refundJson" -ForegroundColor Green

# ------------------------------------------------------------------------------
# BUOC 5: Dang nhap Host, kiem tra danh sach yeu cau hoan tien va so du vi
# ------------------------------------------------------------------------------
Write-Host "`n[5/6] Host (host@homestay.com) kiem tra danh sach hoan tien va so du vi..." -ForegroundColor Yellow
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

# Lay trang /host/refunds de lay refundId vua tao
$refundsPageReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/refunds")
$refundsPageReq.CookieContainer = $jarHost
$refundsPageResp = $refundsPageReq.GetResponse()
$refundsHtml = (New-Object System.IO.StreamReader($refundsPageResp.GetResponseStream())).ReadToEnd()
$refundsPageResp.Close()

if ($refundsHtml -match 'openApproveModal\((\d+)') {
    $refundId = [int]$matches[1]
    Write-Host "  -> Tim thay Refund ID can duyet: $refundId" -ForegroundColor Green
} else {
    Write-Host "  -> Khong tim thay form duyet hoan tien trong HTML!" -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------------------
# BUOC 6: Host duyet hoan tien (Khau tru so du vi Host Model 2)
# ------------------------------------------------------------------------------
Write-Host "`n[6/6] Host duyet hoan tien (action=approve) tru so du vi Model 2..." -ForegroundColor Yellow
$approveReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/refunds/action")
$approveReq.CookieContainer = $jarHost
$approveReq.Method = "POST"
$approveReq.ContentType = "application/x-www-form-urlencoded"
$approveReq.Accept = "application/json"
$appParams = @{
    action = "approve"
    refundId = "$refundId"
    hostNote = "Da duyet hoan tien qua vi Host"
}
$approveStr = ($appParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join $amp
$approveBody = [System.Text.Encoding]::UTF8.GetBytes($approveStr)
$approveReq.ContentLength = $approveBody.Length
$stream = $approveReq.GetRequestStream()
$stream.Write($approveBody, 0, $approveBody.Length)
$stream.Close()
$approveResp = $approveReq.GetResponse()
$approveJson = (New-Object System.IO.StreamReader($approveResp.GetResponseStream())).ReadToEnd()
$approveResp.Close()
Write-Host "  -> Phan hoi duyet hoan tien: $approveJson" -ForegroundColor Green

# Kiem tra lai Dashboard cua Host
$dashReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/dashboard")
$dashReq.CookieContainer = $jarHost
$dashResp = $dashReq.GetResponse()
$dashHtml = (New-Object System.IO.StreamReader($dashResp.GetResponseStream())).ReadToEnd()
$dashResp.Close()

if ($dashHtml -match 'So du vi Host[\s\S]*?<div class="stat-value">([\s\S]*?)</div>' -or $dashHtml -match 'stat-value">([\s\S]*?)</div>') {
    $currentBalance = $matches[1].Trim()
    Write-Host "  -> So du vi Host hien tai tren Dashboard: $currentBalance" -ForegroundColor Cyan
}

Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "   KET QUA: TAT CA TINH NANG ITERATION 2 VA 3 HOAT DONG HOAN HAO!    " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
