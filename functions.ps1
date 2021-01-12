function NameAndShow {
    param (
        [string]$windowName,
        [Emgu.CV.IInputArray]$image
    )
    [Emgu.CV.CvInvoke]::Imshow($windowName , $image)
    [Emgu.CV.CvInvoke]::WaitKey(0)      
    [Emgu.CV.CvInvoke]::DestroyWindow($windowName)  
}

function FlipImageAndShow {
    param (
        [Emgu.CV.IInputArray]$image,
        [Emgu.CV.CvEnum.FlipType]$flipType
    )
    [Emgu.CV.CvInvoke]::Flip($image, $image, $flipType)
    NameAndShow -windowName 'flip' -image $image
}

function Blur {
    param (
        [Emgu.CV.IInputArray]$image
    )
    $kernel = [System.Drawing.Size]::new(8,8)
    $kernel2 = [System.Drawing.Size]::new(-1,-1)
    [Emgu.CV.CvInvoke]::Blur($image, $image, $kernel, $kernel2)
    NameAndShow -windowName 'blur' -image $image
}

function Bitwise {
    param (
        [Emgu.CV.IInputArray]$image1,
        [Emgu.CV.IInputArray]$image2,
        [string]$operationType    
    )
    Write-Host 'Resizing image to perform bitwise operations'
    [Emgu.CV.CvInvoke]::Resize($image2, $image2, [System.Drawing.Size]::new($image1.Width, $image1.Height))
    switch ($operationType) {
        'or' { [Emgu.CV.CvInvoke]::BitwiseOr($image1, $image2, $image1) }
        'and' { [Emgu.CV.CvInvoke]::BitwiseAnd($image1, $image2, $image1) }
        'xor' { [Emgu.CV.CvInvoke]::BitwiseXor($image1, $image2, $image1) }
        'not1' { [Emgu.CV.CvInvoke]::BitwiseNot($image1, $image1) }
        'not2' { 
            [Emgu.CV.CvInvoke]::BitwiseNot($image2, $image2)
            NameAndShow -windowName $operationType -image $image2
            return
        }
    }
    NameAndShow -windowName $operationType -image $image1
}

function Edges {
    param (
        [Emgu.CV.IInputArray]$image,
        [int]$threshold
    )
    $copy = $image.Clone()
    [Emgu.CV.CvInvoke]::Canny($copy, $image, $threshold, $threshold+50)
    NameAndShow -windowName 'edges' -image $image

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
    
    [int]$sigma = $image.Size.Width / 3
    $kernel = GenerateGaussianKernel -X $image.Size.Width -Y $image.Size.Height -sigma $sigma

    [Emgu.CV.CvInvoke]::CvtColor($kernel, $kernel, [Emgu.CV.CvEnum.ColorConversion]::Gray2Rgb)
    [Emgu.CV.CvInvoke]::Multiply($image, $kernel, $output, 1/255)
    NameAndShow -windowName 'Vignette' -image $output
}

function Rotate {
    param (
        [Emgu.CV.Mat]$image,
        [string]$rotateToken
    )

    $ret = 0
    switch ($rotateToken) {
        'ccw' { 
            [Emgu.CV.CvInvoke]::Rotate($image, $image, [Emgu.CV.CvEnum.RotateFlags]::Rotate90CounterClockwise)
            $ret = 1
         }
        Default { [Emgu.CV.CvInvoke]::Rotate($image, $image, [Emgu.CV.CvEnum.RotateFlags]::Rotate90Clockwise) }
    }
    NameAndShow -windowName 'Rotate' -image $image
    
    return $ret
}

function Scale {
    param (
        [Emgu.CV.IInputArray]$image,
        [int]$width,
        [int]$height
    )
    [Emgu.CV.CvInvoke]::Resize($image, $image, [System.Drawing.Size]::new($width, $height))
    NameAndShow -windowName "scale to $width $height" -image $image
}

function DiffImages {
    param (
        [Emgu.CV.IInputArray]$image1,
        [Emgu.CV.IInputArray]$image2
    )
    [Emgu.CV.CvInvoke]::Resize($image2, $image2, [System.Drawing.Size]::new($image1.Width, $image1.Height))
    [Emgu.CV.CvInvoke]::AbsDiff($image1, $image2, $image1)
    NameAndShow -windowName "difference" -image $image1
}

function ToGrayscale {
    param (
        [Emgu.CV.IInputArray]$image
    )
    $placeholder = [Emgu.CV.Mat]::new()
    [Emgu.CV.CvInvoke]::Decolor($image, $image, $placeholder)
    NameAndShow -windowName "gray" -image $image
}

function Normalize {
    param (
        [Emgu.CV.IInputArray]$image
    )
    [Emgu.CV.CvInvoke]::Normalize($image, $image)
    NameAndShow -windowName "normalize" -image $image
}

function Shuffle{
    param (
        [Emgu.CV.IInputArray]$image,
        [double]$iters
    )
    [Emgu.CV.CvInvoke]::RandShuffle($image, $iters, 0)
    NameAndShow -windowName "shuffle" -image $image
}  