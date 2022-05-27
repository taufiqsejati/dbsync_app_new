<?php
	$host	    = "127.0.0.1";
	$account	= "root";
	$password	= "";
	$namadb		= "userdata";

$koneksi = mysqli_connect($host,$account,$password,$namadb);
mysqli_set_charset($koneksi,'utf8');
if(mysqli_connect_errno()){
	echo 'Gagal melakukan koneksi ke Database : '.mysqli_connect_error();
}else{
}
?>