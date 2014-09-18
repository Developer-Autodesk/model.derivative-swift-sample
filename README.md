#Autodesk View And Data API Workflow Sample for MacOS written in Swift

##Description

*This sample is part of the [Developer-Autodesk/Autodesk-View-and-Data-API-Samples](https://github.com/Developer-Autodesk/autodesk-view-and-data-api-samples) repository.*

A Swift MacOS sample that illustrates what is doable with Autodesk View And Data API 

* Upload a file to bucket
* Start translation
* Get thumbnail
* Load it in Viewer

##Dependencies

This requires the latest Xcode that supports the Swift language. At the moment it’s Xcode6-Beta7

##Setup/Usage Instructions

* Type in the Consumer Key and Consumer Secret in the dialog that you got for your application on [https://developer.autodesk.com](https://developer.autodesk.com) 
* Generate Token - this is required before doing any further operation  
* Upload a file for translation
* When a urn (id of a given uploaded file) is selected in the combo box, then the dialog will try to retrieve and display  its thumbnail
* When a urn is selected in the combo box then you can also open the model in the browser
* The project also stores all the urn’s and keys, so that you do not have to type them in the next time you start the program. If you want to delete them then just delete them in the UI and then close the program

## License

This sample is licensed under the terms of the [MIT License](http://opensource.org/licenses/MIT). Please see the [LICENSE](LICENSE) file for full details.

##Written by 

Written by [Adam Nagy](http://adndevblog.typepad.com/cloud_and_mobile/adam-nagy.html)   



