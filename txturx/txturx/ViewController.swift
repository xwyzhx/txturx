//
//  ViewController.swift
//  txturx
//
//  Created by Wendy Zhang on 9/9/16.
//  Copyright © 2016 Wendy Zhang. All rights reserved.
//

import UIKit
import QuartzCore
import AudioToolbox
import AVFoundation
import CoreMotion
import Alamofire
//import AlamofireImage
//import AlamofireNetworkActivityIndicator

class ViewController: UIViewController {
    @IBOutlet weak var numericDisplay: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var setupButton: UIButton!
    
    var timeLeft : NSTimeInterval!
    var timer : NSTimer!
    var currentDateTime: NSDate!
    var systemSoundID: SystemSoundID = 1016
    var timeSet = ""
    var savedNum = ""
    var shakeTimer: NSTimer!
    let motionManager = CMMotionManager()
    var oneMin : NSTimer!
    var alarm: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.numericDisplay.text = "Don't oversleep!"
        
        startButton.layer.cornerRadius = 5
        resetButton.layer.cornerRadius = 5
        setupButton.layer.cornerRadius = 5
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
    //        let pickerLabel = UILabel()
    //        let titleData = datePicker[row]
    //        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
    //        pickerLabel.attributedText = myTitle
    //        return pickerLabel
    //    }
    
    func update() {
        if let accelerometerData = motionManager.accelerometerData {
            print(accelerometerData)
        }
    }
    
    func updateTime() {
        let elapsedTime : NSTimeInterval  = NSDate().timeIntervalSinceDate(currentDateTime)
        let remainingTime : NSTimeInterval = timeLeft - elapsedTime
        
        if remainingTime <= 0.0 {
            timer.invalidate()
            numericDisplay.text = "Now we text your ex."
            becomeAlarmed()
            oneMinWarning(NSDate())
            
            return
        }
        //        if elapsedTime > 5.0 {
        //            numericDisplay.text = "\(Int (remainingTime))"
        //        }
    }
    
    func becomeAlarmed() {
        let path = NSBundle.mainBundle().pathForResource("youth.mp3", ofType: nil)!
        print(path)
        let url = NSURL(fileURLWithPath: path)
        print(url)
        do {
            let sound = try AVAudioPlayer(contentsOfURL: url)
            alarm = sound
            alarm.play()
        } catch {
            // couldn't load file :(
            print("no sound")
        }
    }
    
    func oneMinWarning(start: NSDate) {
        var elapsedTime : NSTimeInterval = NSDate().timeIntervalSinceDate(start)
        while (elapsedTime < 1.0) {
            // keep on the checking
            elapsedTime = NSDate().timeIntervalSinceDate(start)
        }
        print("hell from 1 sec after")
    }
    
    func text(ex: String, msg: String) {
        let params: [String: String] = [
            "api_key": "5b096003",
            "api_secret": "8dd1f80eb85ece92",
            "to": ex,
            "from": "12674055716",
            "text": msg,
            ]
        
        Alamofire.request(.GET, "https://rest.nexmo.com/sms/json?", parameters: params)
            .response { request, response, data, error in
                
                print("is it working?")
                print(request)
                print("hmm")
                print(response)
                
                do {
                    let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options:[])
                    print("Array: \(jsonArray)")
                }
                catch {
                    print("Error: \(error)")
                }
                
                print("oops")
                print(error)
        }
        
    }
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        self.numericDisplay.text = "Alarm set for: " + timeSet
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        let date = dateFormatter.dateFromString(strDate)
        
        currentDateTime = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let datecomponents = calendar.components(.Second, fromDate: currentDateTime, toDate: date!, options: NSCalendarOptions.WrapComponents)
        
        timeLeft = Double (datecomponents.second)
        
        if timeLeft < 0 {
            self.numericDisplay.text = "Please enter a time in the future, unless you want us to text your ex for you now."
            return
        }
        
        let aSelector : Selector = #selector(ViewController.updateTime)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.10, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }
    
    func isAwake(time : NSTimeInterval) -> Bool {
        motionManager.startAccelerometerUpdates()
        shakeTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        
        return false
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        if (timer.valid) {
            timer.invalidate()
        }
        
        alarm.stop()
        self.numericDisplay.text = "Alarm reset."
    }
    
    @IBAction func datePickerAction(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        timeSet = dateFormatter.stringFromDate(datePicker.date)
        self.numericDisplay.text = "Set alarm for \(timeSet)?"
    }
    
    @IBAction func setupPressed(sender: AnyObject) {
        var msg = ""
        if !savedNum.isEmpty {
            msg = "Current number is " + savedNum
        }
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Enter the number of your ex", message: msg, preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.savedNum = textField.text!
            print("Text field: \(textField.text)")
        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

