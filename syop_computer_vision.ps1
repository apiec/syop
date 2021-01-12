function NameAndShow {
    param (
        $windowName,
        $image
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

Add-Type -Path C:\Users\perfe\Desktop\syop\libs\Emgu.CV.Platform.NetStandard.dll

$i = 0
$imgs = ' ', ' '
while ($args[$i].Contains('.png') -or $args[$i].Contains('.jpg')){
    $imgs[$i] = [Emgu.CV.CvInvoke]::Imread('.\' + $args[$i])
    $i++
}


for ( $i = 1; $i -lt $args.count; $i++ ) {
    switch ($args[$i]) 
    {
        'flip1' { FlipImageAndShow -image $imgs[0] -flipType 1 }
        'flip2' { FlipImageAndShow -image $imgs[1] -flipType 1 }
        'flop1' { FlipImageAndShow -image $imgs[0] -flipType 2 }
        'flop2' { FlipImageAndShow -image $imgs[1] -flipType 2 }
        'blur1' { Blur -image $imgs[0] }
        'blur2' { Blur -image $imgs[1] }
        
        
        
    }
} 