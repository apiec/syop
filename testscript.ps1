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

Add-Type -Path .\libs\Emgu.CV.Platform.NetStandard.dll
$img = [Emgu.CV.CvInvoke]::Imread('.\img.png')
FlipImageAndShow -image $img -flipType 1
FlipImageAndShow -image $img -flipType 2

