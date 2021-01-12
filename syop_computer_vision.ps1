. ./functions.ps1
Add-Type -Path .\libs\Emgu.CV.Platform.NetStandard.dll

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
        'vignette1' { Vignette -image $imgs[0] -output $imgs[0]}
        'vignette2' { Vignette -image $imgs[1] -output $imgs[1]}
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
    }
} 
