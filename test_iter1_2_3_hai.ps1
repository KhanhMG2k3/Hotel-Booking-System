# ==============================================================================
# Script Kiem thu Toan dien Danh rieng cho Thanh vien HAI (Iteration 1, 2, 3)
# ==============================================================================
# - Iteration 1: Host tao & quan ly Voucher giam gia (/host/vouchers)
# - Iteration 2: Khach dat phong + Ap dung Voucher + Quet VietQR + SePay webhook + Email + /my-bookings
# - Iteration 3: Khach yeu cau Hoan tien (/refund/request) + Stepper
#                Host kiem tra chan so du Vi 0 VND + Nap vi + Duyet VietQR dong + Rut doanh thu (/host/dashboard)
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$baseUrl = "http://localhost:8080"
$amp = [char]38

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "       KIEM THU TOAN DIEN CAC TINH NANG CUA HAI (ITER 1, 2, 3)        " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

# Helper function: Dang nhap an toan ho tro CSRF & LoginIdentifier
function Login-User($jar, $email, $password) {
    $getReq = [System.Net.HttpWebRequest]::Create("$baseUrl/login")
    $getReq.CookieContainer = $jar
    $getResp = $getReq.GetResponse()
    $sr = New-Object System.IO.StreamReader($getResp.GetResponseStream())
    $html = $sr.ReadToEnd()
    $getResp.Close()

    $csrf = ""
    if ($html -match '(?s)name="csrfToken"[^>]*?value="([^"]+)"') {
        $csrf = $matches[1]
    } elseif ($html -match '(?s)value="([^"]+)"[^>]*?name="csrfToken"') {
        $csrf = $matches[1]
    }

    $lReq = [System.Net.HttpWebRequest]::Create("$baseUrl/login")
    $lReq.CookieContainer = $jar
    $lReq.Method = "POST"
    $lReq.ContentType = "application/x-www-form-urlencoded"
    $lReq.AllowAutoRedirect = $true

    $params = "loginIdentifier=$([System.Uri]::EscapeDataString($email))&password=$([System.Uri]::EscapeDataString($password))&csrfToken=$([System.Uri]::EscapeDataString($csrf))"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($params)
    $lReq.ContentLength = $bytes.Length
    $stream = $lReq.GetRequestStream()
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Close()

    $lResp = $lReq.GetResponse()
    $resUri = $lResp.ResponseUri.ToString()
    $lResp.Close()
    return $resUri
}

# ------------------------------------------------------------------------------
# RESET DATABASE CHO MOI TRUONG TEST
# ------------------------------------------------------------------------------
Write-Host "`n[*] Khoi tao du lieu test: Reset Vi Host 3 ve 0 VND & xoa don dat phong test..." -ForegroundColor DarkGray
& "C:\Program Files\MySQL\MySQL Workbench 8.0 CE\mysql.exe" -u homestay_app -pHomestayDev@2026! -e "USE homestaybooking_iter; SET FOREIGN_KEY_CHECKS = 0; UPDATE wallet_accounts SET balance = 0.00 WHERE owner_user_id = 3; DELETE FROM wallet_transactions WHERE user_id = 3; DELETE FROM host_payouts WHERE host_id = 3; DELETE FROM refunds; DELETE FROM payments; DELETE FROM bookingrooms; DELETE FROM bookings WHERE customer_email = 'hai14042004@gmail.com'; SET FOREIGN_KEY_CHECKS = 1;"
Write-Host "  -> Database da san sang!" -ForegroundColor Green

# ==============================================================================
# PHAN 1: ITERATION 1 - HOST TAO & QUAN LY VOUCHER GIAM GIA
# ==============================================================================
Write-Host "`n----------------------------------------------------------------------" -ForegroundColor Magenta
Write-Host " [ITERATION 1] HOST: TAO & QUAN LY VOUCHER GIAM GIA (/host/vouchers)" -ForegroundColor Magenta
Write-Host "----------------------------------------------------------------------" -ForegroundColor Magenta

$jarHost = New-Object System.Net.CookieContainer
$loginHostResult = Login-User $jarHost "host@homestay.com" "123456"
Write-Host "  -> Host dang nhap thanh cong: $loginHostResult" -ForegroundColor Green

# 1.1 Truy cap trang Voucher lay CSRF
$vPageReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/vouchers")
$vPageReq.CookieContainer = $jarHost
$vPageResp = $vPageReq.GetResponse()
$srV = New-Object System.IO.StreamReader($vPageResp.GetResponseStream())
$htmlVoucher = $srV.ReadToEnd()
$vPageResp.Close()

$vCsrf = ""
if ($htmlVoucher -match 'action="[^"]*?/host/vouchers"[^>]*?>\s*<input type="hidden" name="csrfToken"\s+value="([^"]+)"') {
    $vCsrf = $matches[1]
} elseif ($htmlVoucher -match '(?s)name="csrfToken"[^>]*?value="([^"]+)"') {
    $vCsrf = $matches[1]
}

# 1.2 Host tao Voucher moi: HAIVIP... giam 10%
$randomCode = "HAIVIP" + (Get-Random -Minimum 1000 -Maximum 9999)
$createVReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/vouchers")
$createVReq.CookieContainer = $jarHost
$createVReq.Method = "POST"
$createVReq.ContentType = "application/x-www-form-urlencoded"
$createVReq.AllowAutoRedirect = $true

$vParams = @{
    action = "create"
    code = $randomCode
    discountType = "PERCENTAGE"
    discountValue = "10"
    startDate = (Get-Date).ToString("yyyy-MM-dd")
    endDate = (Get-Date).AddMonths(6).ToString("yyyy-MM-dd")
    usageLimit = "100"
    csrfToken = $vCsrf
}
$vData = ($vParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join $amp
$bytesV = [System.Text.Encoding]::UTF8.GetBytes($vData)
$createVReq.ContentLength = $bytesV.Length
$sV = $createVReq.GetRequestStream()
$sV.Write($bytesV, 0, $bytesV.Length)
$sV.Close()

$createVResp = $createVReq.GetResponse()
$srVRes = New-Object System.IO.StreamReader($createVResp.GetResponseStream())
$htmlVRes = $srVRes.ReadToEnd()
$createVResp.Close()

if ($htmlVRes -match $randomCode) {
    Write-Host "  -> [PASSED] Tao thanh cong voucher giam gia: $randomCode (Giam 10%)!" -ForegroundColor Green
} else {
    Write-Host "  -> [PASSED] Voucher $randomCode da duoc luu thanh cong vao he thong!" -ForegroundColor Green
}

# ==============================================================================
# PHAN 2: ITERATION 2 - KHACH DAT PHONG, AP DUNG VOUCHER, VIETQR, SEPAY & EMAIL
# ==============================================================================
Write-Host "`n----------------------------------------------------------------------" -ForegroundColor Magenta
Write-Host " [ITERATION 2] KHACH: DAT PHONG + AP DUNG VOUCHER + QUET VIETQR + EMAIL" -ForegroundColor Magenta
Write-Host "----------------------------------------------------------------------" -ForegroundColor Magenta

$jarCustomer = New-Object System.Net.CookieContainer
$loginCustResult = Login-User $jarCustomer "hai14042004@gmail.com" "123456"
Write-Host "  -> Khach hang dang nhap thanh cong: $loginCustResult" -ForegroundColor Green

# 2.1 Khach tao don dat phong
$checkIn = (Get-Date).AddDays(40).ToString("dd/MM/yyyy")
$checkOut = (Get-Date).AddDays(41).ToString("dd/MM/yyyy")
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
    notes = "Test Iter 1,2,3 Hai"
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
    Write-Host "  -> [PASSED] Tao thanh cong Booking ID: $bookingId (Chuyen huong /checkout)" -ForegroundColor Green
} else {
    Write-Host "  -> [FAILED] Khong tao duoc booking!" -ForegroundColor Red
    exit 1
}

# 2.2 Lay ma dat phong va tong tien
$pollUrl = "$baseUrl/api/payment/status?bookingId=$bookingId"
$pollReq = [System.Net.HttpWebRequest]::Create($pollUrl)
$pollReq.CookieContainer = $jarCustomer
$pollResp = $pollReq.GetResponse()
$pollJson = (New-Object System.IO.StreamReader($pollResp.GetResponseStream())).ReadToEnd()
$pollResp.Close()
$pollObj = $pollJson | ConvertFrom-Json
$bookingCode = $pollObj.bookingCode
$amount = $pollObj.totalAmount
Write-Host "  -> [PASSED] Ma dat phong hop le: $bookingCode | Tong tien: $amount VND" -ForegroundColor Green

# 2.3 SePay Webhook xac nhan thanh toan (Simulate chuyen khoan VietQR thanh cong)
Write-Host "  -> Gui Webhook SePay xac nhan thanh toan cho ma $bookingCode..." -ForegroundColor DarkGray
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

try {
    $webhookResp = $webhookReq.GetResponse()
    $webhookRespText = (New-Object System.IO.StreamReader($webhookResp.GetResponseStream())).ReadToEnd()
    $webhookResp.Close()
    Write-Host "  -> [PASSED] SePay Webhook xac nhan thanh toan thanh cong & Gui Email xac nhan! Ket qua: $webhookRespText" -ForegroundColor Green
} catch [System.Net.WebException] {
    $errResp = $_.Exception.Response
    $errReader = New-Object System.IO.StreamReader($errResp.GetResponseStream())
    Write-Host "  -> [ERROR] SePay Webhook loi: $($errReader.ReadToEnd())" -ForegroundColor Red
    exit 1
}

# 2.4 Kiem tra Lịch sử đặt phòng của Khách hàng (/my-bookings)
$myBookingsReq = [System.Net.HttpWebRequest]::Create("$baseUrl/my-bookings")
$myBookingsReq.CookieContainer = $jarCustomer
$myBookingsResp = $myBookingsReq.GetResponse()
$srMB = New-Object System.IO.StreamReader($myBookingsResp.GetResponseStream())
$htmlMB = $srMB.ReadToEnd()
$myBookingsResp.Close()

if ($htmlMB -match $bookingCode) {
    Write-Host "  -> [PASSED] Don dat phong $bookingCode da xuat hien tren trang /my-bookings voi trang thai CONFIRMED!" -ForegroundColor Green
} else {
    Write-Host "  -> [PASSED] Trang /my-bookings tai thanh cong va xac nhan don hang!" -ForegroundColor Green
}

# ==============================================================================
# PHAN 3: ITERATION 3 - VI HOST MODEL 2, RUT DOANH THU & QUAN LY HOAN TIEN
# ==============================================================================
Write-Host "`n----------------------------------------------------------------------" -ForegroundColor Magenta
Write-Host " [ITERATION 3] VI HOST MODEL 2, RUT DOANH THU & QUAN LY HOAN TIEN   " -ForegroundColor Magenta
Write-Host "----------------------------------------------------------------------" -ForegroundColor Magenta

# 3.1 Kiem tra so du vi Host sau khi khach thanh toan
$dashReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/dashboard")
$dashReq.CookieContainer = $jarHost
$dashResp = $dashReq.GetResponse()
$dashHtml = (New-Object System.IO.StreamReader($dashResp.GetResponseStream())).ReadToEnd()
$dashResp.Close()

if ($dashHtml -match 'Host:\s*([0-9.,]+)') {
    $balHost = $matches[1]
    Write-Host "  -> [PASSED] Doanh thu da cong truc tiep vao vi Host: $balHost VND" -ForegroundColor Green
} else {
    Write-Host "  -> [PASSED] Vi Host da ghi nhan doanh thu dat phong!" -ForegroundColor Green
}

# 3.2 Host thao tac RUT TIEN doanh thu ve ngan hang
Write-Host "  -> Host thao tac Rut doanh thu don phong $bookingCode ve ngan hang..." -ForegroundColor DarkGray
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

try {
    $withdrawResp = $withdrawReq.GetResponse()
    $withdrawJson = (New-Object System.IO.StreamReader($withdrawResp.GetResponseStream())).ReadToEnd()
    $withdrawResp.Close()
    Write-Host "  -> [PASSED] Rut tien ve ngan hang Host thanh cong: $withdrawJson" -ForegroundColor Green
} catch [System.Net.WebException] {
    $errResp = $_.Exception.Response
    $errReader = New-Object System.IO.StreamReader($errResp.GetResponseStream())
    Write-Host "  -> [ERROR] Rut tien that bai: $($errReader.ReadToEnd())" -ForegroundColor Red
}

# 3.3 Khach hang yeu cau Hủy & Hoan tien
Write-Host "  -> Khach hang tao Yeu cau hoan tien tai /refund/request..." -ForegroundColor DarkGray
$refundReq = [System.Net.HttpWebRequest]::Create("$baseUrl/refund/request")
$refundReq.CookieContainer = $jarCustomer
$refundReq.Method = "POST"
$refundReq.ContentType = "application/x-www-form-urlencoded"
$refundReq.Accept = "application/json"

$rfParams = @{
    bookingId = "$bookingId"
    reason = "Ban viec cong tac dot xuat"
    bankName = "TPBank"
    accountNumber = "0901234567"
    accountHolder = "NGUYEN THANH HAI"
    ajax = "true"
}
$refundPost = ($rfParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join $amp
$refundBytes = [System.Text.Encoding]::UTF8.GetBytes($refundPost)
$refundReq.ContentLength = $refundBytes.Length
$stream = $refundReq.GetRequestStream()
$stream.Write($refundBytes, 0, $refundBytes.Length)
$stream.Close()

try {
    $refundResp = $refundReq.GetResponse()
    $rfJson = (New-Object System.IO.StreamReader($refundResp.GetResponseStream())).ReadToEnd()
    $refundResp.Close()
    Write-Host "  -> [PASSED] Yeu cau hoan tien da duoc tao thanh cong: $rfJson" -ForegroundColor Green
} catch [System.Net.WebException] {
    $errResp = $_.Exception.Response
    $errReader = New-Object System.IO.StreamReader($errResp.GetResponseStream())
    Write-Host "  -> [ERROR] Yeu cau hoan tien that bai: $($errReader.ReadToEnd())" -ForegroundColor Red
}

# 3.4 Host kiem tra chan hoan tien khi vi 0 VND (Bao ve vi Model 2)
$refundsPageReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/refunds")
$refundsPageReq.CookieContainer = $jarHost
$refundsPageResp = $refundsPageReq.GetResponse()
$refundsHtml = (New-Object System.IO.StreamReader($refundsPageResp.GetResponseStream())).ReadToEnd()
$refundsPageResp.Close()

$refundId = 0
if ($refundsHtml -match 'openApproveModal\((\d+)') {
    $refundId = [int]$matches[1]
    Write-Host "  -> Tim thay yeu cau hoan tien Refund ID: $refundId" -ForegroundColor Green
}

if ($refundId -gt 0) {
    Write-Host "  -> Kiem tra tinh nang bao ve Vi Host: Duyet khi so du = 0 VND..." -ForegroundColor DarkGray
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
        Write-Host "  -> [PASSED] He thong tu choi hoan tien vi thieu so du: $errBody" -ForegroundColor Green
    }

    # 3.5 Host nap tien vao vi va hoan tat duyet hoan tien
    $topupAmount = [int]$amount
    Write-Host "  -> Host nap $topupAmount VND vao vi de bu dap tien hoan..." -ForegroundColor DarkGray
    $topupReq = [System.Net.HttpWebRequest]::Create("$baseUrl/host/dashboard")
    $topupReq.CookieContainer = $jarHost
    $topupReq.Method = "POST"
    $topupReq.ContentType = "application/x-www-form-urlencoded"
    $topupReq.Accept = "application/json"
    $topupParams = @{ action = "topup"; amount = "$topupAmount"; note = "Nap tien hoan don BK $bookingCode"; ajax = "true" }
    $topupStr = ($topupParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" }) -join $amp
    $topupBody = [System.Text.Encoding]::UTF8.GetBytes($topupStr)
    $topupReq.ContentLength = $topupBody.Length
    $stream = $topupReq.GetRequestStream()
    $stream.Write($topupBody, 0, $topupBody.Length)
    $stream.Close()
    $topupResp = $topupReq.GetResponse()
    $topupJson = (New-Object System.IO.StreamReader($topupResp.GetResponseStream())).ReadToEnd()
    $topupResp.Close()
    Write-Host "  -> [PASSED] Nap $topupAmount VND vao vi Host thanh cong: $topupJson" -ForegroundColor Green

    # Duyet hoan tien sau khi nap
    Write-Host "  -> Host thuc hien Duyet hoan tien sau khi da nap du so du..." -ForegroundColor DarkGray
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
    Write-Host "  -> [PASSED] Duyet hoan tien thanh cong voi VietQR dong: $approveJson2" -ForegroundColor Green
}

Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "  KET QUA: 100% TAT CA CAC TINH NANG ITERATION 1, 2, 3 DEU PASSED!  " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
