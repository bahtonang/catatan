<?php

//by : zvineyard
if (isset($_POST['pid']))
{
	$pid = $_POST['pid'];
	$filename = $_FILES["image"]["name"];
	$file_basename = substr($filename, 0, strripos($filename, '.')); // get file extention
	$file_ext = substr($filename, strripos($filename, '.')); // get file name
	$filesize = $_FILES["image"]["size"];
	$allowed_file_types = array('.jpg','.jpeg');	

	if (in_array($file_ext,$allowed_file_types) && ($filesize < 200000))
	{	
		// Rename file
		$newfilename = $pid.$file_ext;
		//$newfilename = md5($file_basename) . $file_ext;
	//	if (file_exists("images/" . $newfilename))
	//	{
			// file already exists error
		//	echo "You have already uploaded this file.";
	//	}
	//	else
		//{		
			move_uploaded_file($_FILES["image"]["tmp_name"], "images/" . $newfilename);
		//	echo "File uploaded successfully.";		
	//	}
	}
	elseif (empty($file_basename))
	{	
		// file selection error
		echo "Please select a file to upload.";
	} 
	elseif ($filesize > 200000)
	{	
		// file size error
		echo "The file you are trying to upload is too large.";
	}
	else
	{
		// file type error
		echo "Only these file typs are allowed for upload: " . implode(', ',$allowed_file_types);
		unlink($_FILES["image"]["tmp_name"]);
	}
}

?>
