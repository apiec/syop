function FlipImageAndShow {
    param (
        [Emgu.CV.IInputArray]$image,
        [Emgu.CV.CvEnum.FlipType]$flipType
    )
    $flip = [Emgu.CV.Mat]::new()
    [Emgu.CV.CvInvoke]::Flip($img, $flip, $flipType)
    $windowName = 'flip'
    [Emgu.CV.CvInvoke]::Imshow($windowName , $flip)
    [Emgu.CV.CvInvoke]::WaitKey(0)      
    [Emgu.CV.CvInvoke]::DestroyWindow($windowName)  
}

function GenerateGaussianKernel {
    param (
        [int]$X,
        [int]$Y,
        [double]$sigma
    )
    $s = 2 * $sigma * $sigma
    $max = 0
    $im = [Emgu.CV.Image`2[Emgu.CV.Structure.Gray, Double]]::new([System.Drawing.Size]::new($X, $Y))
    
    for ($yi = 0; $yi -lt $Y; $yi++) {
        for ($xi = 0; $xi -lt $X; $xi++) {
            $xRelative = $xi - $X / 2
            $yRelative = $yi - $Y / 2
            $r = [System.Math]::Sqrt($xRelative *$xRelative + $yRelative * $yRelative)
            $val = [System.Math]::Exp(-($r * $r) / $s) / ([System.Math]::PI * $s)
            $im.Item($xi, $yi) = $val

            if ($val -gt $max) {
                $max = $val
            }
        }
    }   

    $mat = $im.Mat.Clone()
    $mat /= $max
    $mat.ConvertTo($mat, [Emgu.CV.CvEnum.DepthType]::Cv8U, 255)


    return $mat
}

function Vignette {
    param (
        [Emgu.CV.Mat]$image,
        [Emgu.CV.Mat]$output
    )
    
    $kernel = GenerateGaussianKernel -X $image.Size.Width -Y $image.Size.Height -sigma -150

    [Emgu.CV.CvInvoke]::CvtColor($kernel, $kernel, [Emgu.CV.CvEnum.ColorConversion]::Gray2Rgb)
    [Emgu.CV.CvInvoke]::Imshow($windowName , $kernel)
    [Emgu.CV.CvInvoke]::WaitKey(0)      
    [Emgu.CV.CvInvoke]::DestroyWindow($windowName)
    [Emgu.CV.CvInvoke]::Multiply($image, $kernel, $output, 1/255)
}

Add-Type -Path .\libs\Emgu.CV.Platform.NetStandard.dll
$img = [Emgu.CV.CvInvoke]::Imread('.\img.png')

$output = [Emgu.CV.Mat]::new()

Vignette -image $img -output $output

[Emgu.CV.CvInvoke]::Imshow($windowName , $output)
[Emgu.CV.CvInvoke]::WaitKey(0)      
[Emgu.CV.CvInvoke]::DestroyWindow($windowName)

#FlipImageAndShow -image $img -flipType 1
#FlipImageAndShow -image $img -flipType 2
