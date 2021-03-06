. $PSScriptRoot/functions.ps1

Add-Type -Path $PSScriptRoot\libs\Emgu.CV.Platform.NetStandard.dll

$i = 0
$imgs = ' ', ' '

while ($args[$i].Contains('.png') -or
       $args[$i].Contains('.jpg') -or
       $args[$i].Contains('.bmp')) {

    $fileName = $args[$i]
    if ($fileName.substring(0, 2) -eq './' -or $fileName.substring(0, 2) -eq '.\') {
        $callerPath = Get-Location
        $fileName = $fileName.substring(1, $fileName.Length - 1)
        $fileName = $callerPath.ToString() + $fileName
    }

    try {
        $imgs[$i] = [Emgu.CV.CvInvoke]::Imread($fileName)
    }
    catch {
        Write-Error "Did not find file $fileName"
        return
    }
    $i++
}


for ( ;$i -lt $args.Count; $i++ ) {
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
        'vignette1' { Vignette -image $imgs[0] -output $imgs[0]}
        'vignette2' { Vignette -image $imgs[1] -output $imgs[1]}
        'gray1' { ToGrayscale -image $imgs[0] }
        'gray2' { ToGrayscale -image $imgs[1] }
        'rotate1' { 
            if ($i -lt $args.Count) {
                $consumed = Rotate -image $imgs[0] -rotateToken $args[$i + 1]
                if ($consumed -eq 1) {
                    $i++
                }
            }
            else {
                Rotate -image $imgs[0]
            }
        }
        'rotate2' { 
            if ($i -lt $args.Count) {
                $consumed = Rotate -image $imgs[1] -rotateToken $args[$i + 1]
                if ($consumed -eq 1) {
                    $i++
                }
            }
            else {
                Rotate -image $imgs[1]
            }
        }
        'scale1' {
             Scale -image $imgs[0] -width $args[$i+1] -height $args[$i+2] 
             $i += 2
        }
        'scale2' { 
            Scale -image $imgs[1] -width $args[$i+1] -height $args[$i+2] 
            $i += 2
        }
        'norm1' { Normalize -image $imgs[0] }
        'norm2' { Normalize -image $imgs[1] }
        'diff' { DiffImages -image1 $imgs[0] -image2 $imgs[1] }
        'shuffle1' { 
            Shuffle -image $imgs[0] -iters $args[$i+1]
            $i++
        }
        'shuffle2' { 
            Shuffle -image $imgs[1] -iters $args[$i+1]
            $i++
        }
        'multi'{
            Multiply -image1 $imgs[0] -image2 $imgs[1] -param $args[$i+1]
            $i++
         }
        'save' {
            $iter = 0
            while (![string]::IsNullOrEmpty($imgs[$iter]))
            {
                $pathName = Get-Location
                $fileName = $pathName.ToString() + "\" + ($iter + 1).ToString() + ".png"
                $imgs[$iter].save($fileName)
                Write-Host "File $fileName succesfully saved."
                $iter++
                if ($iter -eq 2) {
                    break
                }
            } 
        }
    }
} 

