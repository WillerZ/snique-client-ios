<?php
header_remove('x-powered-by');
header_remove('content-location');
$_next = 1;

function xgetrandmax()
{
  return 32767;
}

function _xrand()
{
  global $_next;
  $_next = (int) $_next * 1103515245 + 12345;
  return (int) abs($_next / 65536 % (xgetrandmax() + 1));
}

function xrand($min = 0, $max = NULL)
{
  if (isset($min) && isset($max))
  {
    return _xrand() % ($max - $min + 1) + $min;
  }
  return _xrand();
}

function xsrand($seed)
{
  global $_next;
  $_next = abs((int) $seed % (xgetrandmax() + 1));
}

$message = file_get_contents('./.message');
$etags = str_split($message, 8);
$num = $_GET["index"];
$etag = $etags[intval($num)];
$etag = str_replace("\n",'',$etag);
srand(intval($num));
$chars = 'abcdef0123456789';
while (strlen($etag) < 8)
{
  $etag .= $chars[rand(0, 16)];
}
$if_none_match = isset($_SERVER['HTTP_IF_NONE_MATCH']) ?
	 stripslashes($_SERVER['HTTP_IF_NONE_MATCH']) : 
		 false ;

if( false !== $if_none_match )
{
  $tags = split( ", ", $if_none_match ) ;
  foreach( $tags as $tag )
  {
    if( $tag == $etag )
    {
      header( "HTTP/1.1 304 NOT MODIFIED" );
      exit;
    }
  }
}
header( "HTTP/1.1 200 OK" );
header( "Content-Type: image/png" );
header( "Cache-Control: public, max-age=60, no-transform, must-revalidate" );
header( 'Etag: "'.$etag.'"' );
$im = imagecreate(40,40);
imagecolorallocate($im, 255, 255, 255);
$black = imagecolorallocate($im, 0, 0, 0);
imagestring($im, 5, 0, 0, $num, $black);
imagepng($im);
imagedestroy($im);
exit;
?>
