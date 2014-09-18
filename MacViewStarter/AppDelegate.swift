//
//  AppDelegate.swift
//  MacViewStarter
//
//  Created by Adam Nagy on 17/09/2014.
//  Copyright (c) 2014 Adam Nagy. All rights reserved.
//

import Cocoa

class AppDelegate:
NSObject, NSApplicationDelegate, NSComboBoxDelegate {
  
  let viewerUrl = "https://developer.api.autodesk.com"
  
  @IBOutlet weak var window: NSWindow!
  
  @IBOutlet weak var consumerKey: NSTextField!
  @IBOutlet weak var consumerSecret: NSTextField!
  @IBOutlet weak var accessToken: NSTextField!
  @IBOutlet weak var fileUrn: NSComboBox!
  @IBOutlet weak var fileThumbnail: NSImageView!
  
  @IBAction func generateToken(sender: AnyObject) {
    logIn();
  }
  
  // Open the webpage of the project: index.html
  @IBAction func openWebpage(sender: AnyObject) {
    // Get the file path
    var mainBundle = NSBundle.mainBundle()
    var path = mainBundle.pathForResource("index", ofType:"html")
    var url = NSURL.fileURLWithPath(path!)
    path = url?.absoluteString
    
    // Add the query string
    path! += "?accessToken=" + accessToken.stringValue
    path! += "&urn=" + fileUrn.stringValue
    
    // Create URL for that
    url = NSURL(string: path!)
    
    // Open it in browser
    NSWorkspace.sharedWorkspace().openURL(url)
  }
  
  @IBAction func uploadFile(sender: AnyObject) {
    // Select a file first
    var filePath = openFileDialog(
      "File Upload", message: "Select file to upload")
    
    var fileData = NSData(contentsOfURL: NSURL(string: filePath))
    
    var fileName = filePath.lastPathComponent
    
    // Now we can try to create a bucket
    var body = NSString(format:
      "{ \"bucketKey\":\"mytestbucket\",\"policy\":\"transient\"," +
      "\"servicesAllowed\":{}}")
    
    var json =
    
    httpTo(viewerUrl + "/oss/v1/buckets",
      data: body.dataUsingEncoding(NSUTF8StringEncoding)!,
      contentType: "application/json",
      method: "POST",
      statusCode: nil)
    
    // Now we try to upload the file
    var url = NSString(format:"%@/%@",
      viewerUrl + "/oss/v1/buckets/mytestbucket/objects",
      fileName.stringByAddingPercentEscapesUsingEncoding(
        NSUTF8StringEncoding)!);
    
    json =
      httpTo(url, data: fileData,
        contentType: "application/stream",
        method: "PUT", statusCode: nil)
    
    var objects: AnyObject =
    json!.objectForKey("objects")!.objectAtIndex(0)
    
    var fileKey = objects.objectForKey("key") as NSString
    var fileSha1 = objects.objectForKey("sha-1")as NSString
    var fileId = objects.objectForKey("id")as NSString
    
    NSLog("fileKey = %@", fileKey);
    NSLog("fileSha1 = %@", fileSha1);
    NSLog("fileId = %@", fileId);
    
    var data = fileId.dataUsingEncoding(NSUTF8StringEncoding)
    var fileUrn64 = data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
    NSLog("fileUrn64 = %@", fileUrn64)
    
    fileUrn.addItemWithObjectValue(fileUrn64)
    
    // Send for translation
    body = NSString(format: "{\"urn\":\"%@\"}", fileUrn64)
    
    var statusCode: NSInteger? = nil
    
    json =
      httpTo(viewerUrl + "/viewingservice/v1/register",
        data: body.dataUsingEncoding(NSUTF8StringEncoding)!,
        contentType:"application/json; charset=utf-8",
        method:"POST",
        statusCode: statusCode)
  }
  
  func comboBoxSelectionDidChange(notification: NSNotification!) {
    var changedRow = fileUrn.indexOfSelectedItem;
    var value: AnyObject! = fileUrn.objectValueOfSelectedItem
    var str = value as NSString
    
    showThumbnail(str)
  }
  
  // Show thumbnail of currently selected file
  func showThumbnail(urn: NSString) {
    var url =
    NSString(format:"%@%@",
      viewerUrl + "/viewingservice/v1/thumbnails/", urn)
    var data = NSData(contentsOfURL: NSURL(string: url))
    
    fileThumbnail.image = NSImage(data: data)
  }
  
  func openFileDialog(title: String, message: String) -> String {
    var myFileDialog: NSOpenPanel = NSOpenPanel()
    
    myFileDialog.prompt = "Open"
    myFileDialog.worksWhenModal = true
    myFileDialog.allowsMultipleSelection = false
    myFileDialog.canChooseDirectories = false
    myFileDialog.resolvesAliases = true
    myFileDialog.title = title
    myFileDialog.message = message
    myFileDialog.runModal()
    var chosenfile = myFileDialog.URL
    if (chosenfile != nil) {
      var theFile = chosenfile.absoluteString!
      return (theFile)
    } else {
      return ("")
    }
  }
  
  func applicationDidFinishLaunching(aNotification: NSNotification?) {
    // Insert code here to initialize your application
    
    // Load Consumer Key, Consumer Secret, urn
    var prefs = NSUserDefaults.standardUserDefaults()
    var cKey: AnyObject? =
    NSUserDefaults.objectForKey(prefs)("ConsumerKey")
    var cSecret: AnyObject? =
    NSUserDefaults.objectForKey(prefs)("ConsumerSecret")
    var fUrn: AnyObject? = NSUserDefaults.objectForKey(prefs)("urn")
    var fUrns: AnyObject? = NSUserDefaults.objectForKey(prefs)("urns")
    if (cKey != nil) {
      consumerKey.stringValue = cKey! as NSString
    }
    if (cSecret != nil) {
      consumerSecret.stringValue = cSecret! as NSString
    }
    if (fUrn != nil) {
      fileUrn.stringValue = fUrn! as NSString
    }
    if (fUrns != nil) {
      deserializeUrns(fUrns! as NSString)
    }
  }
  
  func serializeUrns() -> NSString {
    var urns = ""
    var values = fileUrn.objectValues
    for urn in fileUrn.objectValues {
      urns += urn as NSString + ";"
    }
    
    return urns as NSString
  }
  
  func deserializeUrns(urnsText: NSString) {
    var urns = urnsText.componentsSeparatedByString(";")
    urns.removeLast()
    fileUrn.addItemsWithObjectValues(urns)
  }
  
  func applicationWillTerminate(aNotification: NSNotification?) {
    // Insert code here to tear down your application
    
    // Save Consumer Key, Consumer Secret, urn
    // By default it's stored in:
    // ~/Library/Preferences/com.autodesk.MacViewStarter.plist
    // Might be here too:
    // ~/Library/SyncedPreferences/com.autodesk.MacViewStarter.plist
    var prefs = NSUserDefaults.standardUserDefaults()
    prefs.setObject(consumerKey.stringValue, forKey:"ConsumerKey")
    prefs.setObject(
      consumerSecret.stringValue, forKey:"ConsumerSecret")
    prefs.setObject(fileUrn.stringValue, forKey:"urn")
    prefs.setObject(serializeUrns(), forKey:"urns")
    prefs.synchronize()
  }
  
  // Send an http request
  func httpTo(url: NSString, data: NSData, contentType: NSString,
    method: NSString, var statusCode: NSInteger?) -> NSDictionary? {
      var req = NSMutableURLRequest(
        URL: NSURL(string: url))
      
      req.HTTPMethod = method
      req.setValue(contentType, forHTTPHeaderField: "Content-Type")
      req.HTTPBody = data
      
      var response:
        AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
      var error: NSErrorPointer = nil
      var result = NSURLConnection.sendSynchronousRequest(
        req, returningResponse: response, error: error)
      
      if (statusCode != nil && response != nil) {
        var httpResponse = response.memory!
        statusCode! = (httpResponse as NSHTTPURLResponse).statusCode
      }
      
      if (result != nil && result!.length > 0) {
        var json = NSJSONSerialization.JSONObjectWithData(
          result!,
          options: NSJSONReadingOptions.MutableContainers,
          error: error) as NSDictionary
        
        return json
      }
      
      return nil;
  }
  
  // Log in to the Autodesk system
  func logIn() {
    var body = NSString(
      format: "client_id=%@&client_secret=%@&grant_type=client_credentials",
      consumerKey.stringValue!, consumerSecret.stringValue!).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    
    var json = httpTo(
      viewerUrl + "/authentication/v1/authenticate",
      data: body!.dataUsingEncoding(NSUTF8StringEncoding)!,
      contentType: "application/x-www-form-urlencoded", method: "POST",
      statusCode: nil)
    
    accessToken.stringValue = json!.objectForKey("access_token") as NSString
    
    // Set token to authorize additional calls
    setToken()
  }
  
  // Needed to run before accessing any resources
  func setToken() {
    var body = NSString(format:
      "access-token=%@", accessToken.stringValue).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    
    var statusCode: NSInteger? = 0
    
    var json =
    httpTo(viewerUrl + "/utility/v1/settoken",
      data: body!.dataUsingEncoding(NSUTF8StringEncoding)!,
      contentType: "application/x-www-form-urlencoded",
      method: "POST",
      statusCode: statusCode)
  }
}


