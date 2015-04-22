# LeSMEx
The Legacy Site Map Extractor finds the html files in the root folder of each module for the selected course and creates a Course Framework 4.x Site Map.

Installation:

Install Coldfusion Development Server (local): https://www.adobe.com/cfusion/tdrc/index.cfm?product=coldfusion#

(you may need to create a free Adobe account for this download)

When you install Coldfusion locally, follow the installation wizard and make sure to check 'standalone server' as the installation type.

Once installation is complete, you will have a Coldfusion11 folder in Applications on Mac and on your root C: folder in Windows. Create a folder named 'lesmex' within the 'Coldfusion11/cfusion/wwwroot' folder and place the unzipped LeSMEx file within.

Make sure you move the 'inc_config.cfm' file from the 'put_in_root' folder into the main folder next to the other root files such as index.cfm. Once that file is moved, simply update the values in quotes to your ftp credentials for Educator. 

By default you should be able to visit: http://localhost:8500/lesmex and begin using the LeSMEx tool.
