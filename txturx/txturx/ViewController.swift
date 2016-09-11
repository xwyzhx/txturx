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

class ViewController: UIViewController {
    @IBOutlet weak var numericDisplay: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var timeLeft : NSTimeInterval!
    var timer : NSTimer!
    var currentDateTime: NSDate!
    var audioPlayer = AVAudioPlayer()
    var timeSet = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.numericDisplay.text = "Don't oversleep!"
//        self.resetButton.setTitle("Reset", forState: UIControlState.Normal)
//        self.startButton.setTitle("Set", forState: UIControlState.Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTime() {
        let elapsedTime : NSTimeInterval  = NSDate().timeIntervalSinceDate(currentDateTime)
        let remainingTime : NSTimeInterval = timeLeft - elapsedTime
        
        if remainingTime <= 0.0 {
            timer.invalidate()
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            numericDisplay.text = "Now we text your ex."
            return
        }
//        if elapsedTime > 5.0 {
//            numericDisplay.text = "\(Int (remainingTime))"
//        }
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
        
        let aSelector : Selector = #selector(ViewController.updateTime)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.10, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }

    @IBAction func resetButtonPressed(sender: AnyObject) {
        timer.invalidate()
        self.numericDisplay.text = "Alarm reset."
    }
    
    @IBAction func datePickerAction(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        timeSet = dateFormatter.stringFromDate(datePicker.date)
        self.numericDisplay.text = "Set alarm for \(timeSet)?"
    }
}

