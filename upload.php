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


Forgive me if this is considered cross posting. I just wanted this to show up for any one searching for file path and renaming. I used various codes on this forum and worked out the following solution.
Goal : Upload a file (Filename), then set the file name along with it’s path into the table.
After setting the form, I went to the onApplicationInit event and set the following
if ((substr($_SERVER[‘HTTP_HOST’],-4) == ‘8090’) OR (substr($_SERVER[‘HTTP_HOST’],-4) == ‘8090’)) { // Current Port?
$prod = TRUE;
[fpg] = “…/…/…/file/pdffiles/”;

} else {
$prod = FALSE;
[fpg] = “…/_lib/file/doc/pdffiles/”;
}
PLEASE NOTE : THE 8090 above could be different in your system

Next against the field general settings (under which the document is uploaded),I set the sub folder value to [fpg]

Next in the after onAfterInsert event I put the following code :
$fp = [fpg];
//In the following part I am generating new file name by adding recordID newly generated , I am splitting the filename into 2 parts primary and extension. then I am adding the recordid to the primary part., after that adding the extension

$filename_in_parts = explode(’.’, {document_upload_path});
$newfilename = $filename_in_parts[0] .$document_id ."." .$filename_in_parts[1]; // existing primary name, record ID, period separator, then extension
$filename = $fp .{document_upload_path};
$newfilename = $fp .$newfilename;

//following is actual code to rename the file to above generated new file name

if(file_exists($newfilename))
    { 
       echo "Error While Renaming $filename" ;
    }
else
    {
       if(rename( $filename, $newfilename))
       { 
       //echo "Successfully Renamed $filename to $newfilename" ;
       }
      else
      {
       echo "A File With The Same Name Already Exists" ;
      }
    }
sc_commit_trans(); // THIS IS VERY MUCH NECESSARY. I HAD PROBLEMS without this. I am generating record id using AutoIncrement (Manual).
// Therefore when I am trying to search for the new record in the update command below the record is not found. I crossed check with the database table and the record was not getting inserted. // So I use the commit trans.

/**

Update a record on another table
*/
// SQL statement parameters
$update_table = ‘documents’; // Table name
$update_where = “document_id = " .{document_id}; // Where clause
$update_fields = array( // Field list, add as many as needed
“document_upload_path = '” .$newfilename .”’",

);

// Update record
$update_sql = ‘UPDATE ’ . $update_table
. ’ SET ’ . implode(’, ', $update_fields)
. ’ WHERE ’ . $update_where;
echo $update_sql;
sc_exec_sql($update_sql);

