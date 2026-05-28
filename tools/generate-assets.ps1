$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "assets"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Color-Hex {
    param(
        [string]$Hex,
        [int]$Alpha = 255
    )
    $clean = $Hex.TrimStart("#")
    $r = [Convert]::ToInt32($clean.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($clean.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($clean.Substring(4, 2), 16)
    return [System.Drawing.Color]::FromArgb($Alpha, $r, $g, $b)
}

function Add-RoundedRectPath {
    param(
        [System.Drawing.Drawing2D.GraphicsPath]$Path,
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H,
        [float]$R
    )
    $d = $R * 2
    $Path.AddArc($X, $Y, $d, $d, 180, 90)
    $Path.AddArc($X + $W - $d, $Y, $d, $d, 270, 90)
    $Path.AddArc($X + $W - $d, $Y + $H - $d, $d, $d, 0, 90)
    $Path.AddArc($X, $Y + $H - $d, $d, $d, 90, 90)
    $Path.CloseFigure()
}

function Draw-ScanImage {
    param(
        [string]$FileName,
        [string]$Kind,
        [string[]]$Palette,
        [int]$Seed
    )

    $w = 1200
    $h = 680
    $rand = [System.Random]::new($Seed)
    $bitmap = [System.Drawing.Bitmap]::new($w, $h)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

    $rect = [System.Drawing.Rectangle]::new(0, 0, $w, $h)
    $bg = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rect,
        [System.Drawing.Color]::FromArgb(255, 1, 1, 2),
        [System.Drawing.Color]::FromArgb(255, 18, 20, 21),
        22
    )
    $graphics.FillRectangle($bg, $rect)
    $bg.Dispose()

    $gridPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(28, 255, 255, 255), 1)
    for ($x = 0; $x -lt $w; $x += 70) {
        $graphics.DrawLine($gridPen, $x, 0, $x + 160, $h)
    }
    for ($y = 0; $y -lt $h; $y += 68) {
        $graphics.DrawLine($gridPen, 0, $y, $w, $y + 20)
    }
    $gridPen.Dispose()

    for ($i = 0; $i -lt 85; $i++) {
        $c = Color-Hex $Palette[$rand.Next(0, $Palette.Count)] $rand.Next(30, 95)
        $pen = [System.Drawing.Pen]::new($c, $rand.Next(1, 4))
        $x1 = $rand.Next(-80, $w)
        $y1 = $rand.Next(-40, $h)
        $x2 = $x1 + $rand.Next(-180, 260)
        $y2 = $y1 + $rand.Next(-160, 220)
        if (($i % 3) -eq 0) {
            $graphics.DrawEllipse($pen, $x1, $y1, $rand.Next(55, 270), $rand.Next(35, 180))
        } else {
            $graphics.DrawLine($pen, $x1, $y1, $x2, $y2)
        }
        $pen.Dispose()
    }

    switch ($Kind) {
        "medical" {
            $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
            Add-RoundedRectPath $path 690 86 360 470 80
            $brush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
                [System.Drawing.Rectangle]::new(680, 80, 390, 500),
                (Color-Hex $Palette[0] 108),
                (Color-Hex $Palette[1] 42),
                92
            )
            $graphics.FillPath($brush, $path)
            $graphics.DrawPath([System.Drawing.Pen]::new((Color-Hex $Palette[2] 150), 5), $path)
            $brush.Dispose()
            $path.Dispose()
            for ($i = 0; $i -lt 9; $i++) {
                $pen = [System.Drawing.Pen]::new((Color-Hex $Palette[$i % $Palette.Count] 140), 3)
                $graphics.DrawEllipse($pen, 735 + ($i * 21), 150 + ($i * 23), 155, 96)
                $pen.Dispose()
            }
        }
        "drone" {
            for ($i = 0; $i -lt 4; $i++) {
                $cx = 300 + (($i % 2) * 540)
                $cy = 170 + ([Math]::Floor($i / 2) * 300)
                $pen = [System.Drawing.Pen]::new((Color-Hex $Palette[$i % $Palette.Count] 175), 9)
                $graphics.DrawEllipse($pen, $cx - 110, $cy - 70, 220, 140)
                $graphics.DrawLine($pen, $cx, $cy, 590, 340)
                $pen.Dispose()
            }
            $bodyBrush = [System.Drawing.SolidBrush]::new((Color-Hex $Palette[1] 120))
            $graphics.FillEllipse($bodyBrush, 500, 250, 210, 160)
            $bodyBrush.Dispose()
        }
        "reshore" {
            for ($i = 0; $i -lt 8; $i++) {
                $x = 160 + ($i * 110)
                $brush = [System.Drawing.SolidBrush]::new((Color-Hex $Palette[$i % $Palette.Count] (55 + ($i % 3) * 25)))
                $graphics.FillRectangle($brush, $x, 145 + (($i % 2) * 68), 76, 370 - (($i % 3) * 38))
                $brush.Dispose()
                $graphics.DrawRectangle([System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(80, 255, 255, 255), 2), $x, 145 + (($i % 2) * 68), 76, 370 - (($i % 3) * 38))
            }
        }
        "electronics" {
            for ($i = 0; $i -lt 9; $i++) {
                $x = 120 + ($i * 108)
                $pen = [System.Drawing.Pen]::new((Color-Hex $Palette[$i % $Palette.Count] 150), 4)
                $graphics.DrawRectangle($pen, $x, 168 + (($i % 3) * 72), 82, 116)
                $graphics.DrawLine($pen, $x + 40, 285, $x + 40, 520)
                $pen.Dispose()
            }
            for ($i = 0; $i -lt 54; $i++) {
                $brush = [System.Drawing.SolidBrush]::new((Color-Hex $Palette[$i % $Palette.Count] 130))
                $graphics.FillEllipse($brush, $rand.Next(80, 1120), $rand.Next(100, 570), 12, 12)
                $brush.Dispose()
            }
        }
        "battery" {
            for ($i = 0; $i -lt 6; $i++) {
                $x = 205 + ($i * 135)
                $brush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
                    [System.Drawing.Rectangle]::new($x, 112, 82, 456),
                    (Color-Hex $Palette[$i % $Palette.Count] 120),
                    [System.Drawing.Color]::FromArgb(20, 0, 0, 0),
                    90
                )
                $graphics.FillRectangle($brush, $x, 112, 82, 456)
                $graphics.DrawRectangle([System.Drawing.Pen]::new((Color-Hex $Palette[(($i + 1) % $Palette.Count)] 125), 3), $x, 112, 82, 456)
                $brush.Dispose()
            }
        }
        "aerospace" {
            $points = @(
                [System.Drawing.PointF]::new(230, 450),
                [System.Drawing.PointF]::new(870, 190),
                [System.Drawing.PointF]::new(1025, 260),
                [System.Drawing.PointF]::new(390, 505)
            )
            $brush = [System.Drawing.SolidBrush]::new((Color-Hex $Palette[0] 95))
            $graphics.FillPolygon($brush, $points)
            $brush.Dispose()
            $graphics.DrawPolygon([System.Drawing.Pen]::new((Color-Hex $Palette[2] 170), 5), $points)
            for ($i = 0; $i -lt 6; $i++) {
                $pen = [System.Drawing.Pen]::new((Color-Hex $Palette[$i % $Palette.Count] 130), 3)
                $graphics.DrawBezier($pen, 260, 520 - ($i * 45), 470, 290, 700, 580, 1030, 205 + ($i * 32))
                $pen.Dispose()
            }
        }
        "packaging" {
            for ($i = 0; $i -lt 7; $i++) {
                $x = 145 + ($i * 130)
                $brush = [System.Drawing.SolidBrush]::new((Color-Hex $Palette[$i % $Palette.Count] 90))
                $graphics.FillRectangle($brush, $x, 130, 68, 430)
                $graphics.FillEllipse($brush, $x - 7, 95, 82, 78)
                $brush.Dispose()
                $graphics.DrawLine([System.Drawing.Pen]::new((Color-Hex $Palette[(($i + 1) % $Palette.Count)] 150), 4), $x, 180, $x + 68, 180)
            }
        }
        default {
            for ($i = 0; $i -lt 16; $i++) {
                $brush = [System.Drawing.SolidBrush]::new((Color-Hex $Palette[$i % $Palette.Count] 78))
                $graphics.FillEllipse($brush, $rand.Next(80, 1040), $rand.Next(70, 500), $rand.Next(80, 220), $rand.Next(70, 190))
                $brush.Dispose()
            }
        }
    }

    $shade = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.Rectangle]::new(0, 0, $w, $h),
        [System.Drawing.Color]::FromArgb(115, 0, 0, 0),
        [System.Drawing.Color]::FromArgb(0, 0, 0, 0),
        0
    )
    $graphics.FillRectangle($shade, 0, 0, $w, $h)
    $shade.Dispose()

    $pathOut = Join-Path $outDir $FileName
    $bitmap.Save($pathOut, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
}

$assets = @(
    @{ File = "scan-medical.png"; Kind = "medical"; Seed = 101; Palette = @("#34d3ff", "#29f6a1", "#f6d44b", "#4854ff") },
    @{ File = "scan-drone.png"; Kind = "drone"; Seed = 202; Palette = @("#4adfff", "#7866ff", "#ff8f3f", "#27e29c") },
    @{ File = "scan-reshoring.png"; Kind = "reshore"; Seed = 303; Palette = @("#e9e9e9", "#2ed3ff", "#ffdb4a", "#ff4f5e") },
    @{ File = "scan-quality.png"; Kind = "default"; Seed = 404; Palette = @("#41ffe1", "#f8db4d", "#6477ff", "#ff5967") },
    @{ File = "scan-cosmetics.png"; Kind = "medical"; Seed = 505; Palette = @("#ff66d5", "#44edff", "#f4e64d", "#8b70ff") },
    @{ File = "scan-solder.png"; Kind = "electronics"; Seed = 606; Palette = @("#5cf0ff", "#a1ff57", "#ffcf4a", "#ff4b74") },
    @{ File = "scan-packaging.png"; Kind = "packaging"; Seed = 707; Palette = @("#19f0a2", "#e33845", "#37a8ff", "#ffda4c") },
    @{ File = "scan-automotive.png"; Kind = "reshore"; Seed = 808; Palette = @("#ff9a35", "#37e6c3", "#5795ff", "#d7ff4d") },
    @{ File = "scan-powerbank.png"; Kind = "battery"; Seed = 909; Palette = @("#ff4858", "#3fd9ff", "#fbe34d", "#53f078") },
    @{ File = "scan-diecasting.png"; Kind = "default"; Seed = 1001; Palette = @("#b5b5b5", "#ff8d36", "#42e2ff", "#ffe66a") },
    @{ File = "scan-battery.png"; Kind = "battery"; Seed = 1102; Palette = @("#f6dd4d", "#2de2a3", "#4fb6ff", "#ff6a6a") },
    @{ File = "scan-aerospace.png"; Kind = "aerospace"; Seed = 1203; Palette = @("#6fe8ff", "#ffcf5c", "#6d7cff", "#33e09d") }
)

foreach ($asset in $assets) {
    Draw-ScanImage -FileName $asset.File -Kind $asset.Kind -Palette $asset.Palette -Seed $asset.Seed
}

Write-Host "Generated $($assets.Count) image assets in $outDir"
