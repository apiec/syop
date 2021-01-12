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
    # $flip = [Emgu.CV.Mat]::new()
    [Emgu.CV.CvInvoke]::Flip($image, $image, $flipType)
    NameAndShow -windowName 'flip' -image $image
}

function Blur {
    param (
        [Emgu.CV.IInputArray]$image
    )
    # $outImage = [Emgu.CV.Mat]::new()
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
    [Emgu.CV.CvInvoke]::Resize($image2, $image2, [System.Drawing.Size]::new($imgs[0].Width, $imgs[0].Height))
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
    $edges = [Emgu.CV.Mat]::new()
    [Emgu.CV.CvInvoke]::Canny($image, $edges, $threshold, $threshold+50)
    NameAndShow -windowName 'edges' -image $edges

}

Add-Type -Path C:\Users\perfe\Desktop\syop\libs\Emgu.CV.Platform.NetStandard.dll

$i = 0
$imgs = ' ', ' '
while ($args[$i].Contains('.png') -or $args[$i].Contains('.jpg')){
    $imgs[$i] = [Emgu.CV.CvInvoke]::Imread('.\' + $args[$i])
    $i++
}


for ( ;$i -lt $args.count; $i++ ) {
    switch ($args[$i]) 
    {
        'flip1' { FlipImageAndShow -image $imgs[0] -flipType 1 }
        'flip2' { FlipImageAndShow -image $imgs[1] -flipType 1 }
        'flop1' { FlipImageAndShow -image $imgs[0] -flipType 2 }
        'flop2' { FlipImageAndShow -image $imgs[1] -flipType 2 }
        'blur1' { Blur -image $imgs[0] }
        'blur2' { Blur -image $imgs[1] }
        {$_ -in 'or', 'and', 'xor', 'not1', 'not2'} 
        { Bitwise -image1 $imgs[0] -image2 $imgs[1] -operationType $args[$i] } 
        'edges1' { 
            Edges -image $imgs[0] -threshold $args[$i+1]
            $i++
        }
        'edges2' {
            Edges -image $imgs[1] -threshold $args[$i+1]
            $i++
         }
    }
} 
