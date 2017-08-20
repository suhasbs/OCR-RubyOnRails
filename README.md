Readme – Bill Reader 

This application has been developed using the Tesseract(3.05.01dev) open source library for Optical Character Recognition, using the Leptonica (1.74.1) Libraries for Image Processing. 
The basic use case of this project is to read the ‘total amount’ from a bill and draw a box around it. As the program is not always right, an additional functionality for the user to draw the box himself is also present. 
[An additional functionality to create an invoice from the bill also has been provided. The user should draw boxes over the required fields like Name, Address and Total and a small invoice with these fields filled will pop up in the app.]
The application has two parts to it, the front end and the server-side. The front end has been developed in Ionic (v1) framework and presently is functioning fully as explained above.
The server-side has been written in Rails (5.1.1) and ruby (2.2.6p396). 

The steps involved in using this application are as follows:
1. Select an image to be uploaded.
2. Crop the image so that only the bill is focused.
3. Upload the image to the server.
4. Wait for the server to run the OCR on the image.
5. The server returns a set of coordinates which is used to draw the box around the amount.
6. If the user is not happy, he can draw the box himself and resend the new coordinates to the server to recognize the numbers. 



Steps before pushing the server-side to production:
1. Install tesseract library and leptonica library.
2. Add the location path of the installed folder to the ‘PATH’ Variable (Environment variable in Windows!). [So, if I open a terminal in the server and type tesseract, the command should be valid]
3. Add an environment variable called ‘TESSDATA_PREFIX’ to ‘{PATH_TO_LIBRARY}/Tesseract_OCR/tessdata’
4. This is required because the server creates a new process (popen) to run the OCR on every image uploaded. 
5. The SQL database being used has 1 table, with 3 fields – (a) filename 
(b) path (c) status
6. Filename and path are of ‘string’ data type and status is of ‘integer’ data type.



The server calls involved are as follows:
1. Upload the image: root/ocr/upload/   - POST
2. Receive coordinates: root/ocr/:id/get_coordinates/ - GET
3. Resend the coordinates: root/ocr/:id/predict_with_coordinates/  - POST


Gems used:
1. Nokogiri
2. Fileutils
3. Securerandom
4. Image_size



Known Bugs:
1. During cropping, there is a loss in quality of the image(due to internal memory issues), which affects the functionality. This is a drawback of the ‘cordova-crop-plugin’.
2. Images with shadows and text with particular fonts are not recognized properly by the software. The clarity of the image(text) needs to be good and should be human readable.
3. Not completely functional with ioS due to image resolution issues.(Not tested with iPhone) 
4. The styling of the application also needs some improvement.  




 

