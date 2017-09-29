//
//  ViewController.swift
//  SpriteKit
//
//  Created by Vianka Barboza on 9/25/17.
//  Copyright © 2017 Vianka Barboza. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let activityManager = CMMotionActivityManager();
    let pedometer = CMPedometer();
    let motion = CMMotionManager()
    let userDefaults = UserDefaults.standard
    var currentGaol = "0"
    var stepsYesterday: Float = 0.0
    var stepsToday: Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
                self.todaysSteps.text = "Steps Today: \(newtotalSteps)"
                //                self.userDefaults.set(newtotalSteps, forKey: "steps")
            }
        }
    }
    let calendar = Calendar.current
    var yesterday = Date();
    var today = Date();
    let steps = ["0","1000", "2000", "3000", "4000", "5000", "6000", "7000", "8000", "9000", "10000"]
    
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var stepLable: UILabel!
    @IBOutlet weak var todaysSteps: UILabel!
    @IBOutlet weak var yesterdaysSteps: UILabel!
    @IBOutlet weak var movementLable: UILabel!
    @IBOutlet weak var goalPicker: UIPickerView!
    @IBOutlet weak var gameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let userDefaults = UserDefaults.standard
        self.stepsToday = 0.0
        self.stepsYesterday = 0.0
        goalPicker.delegate = self
        goalPicker.dataSource = self
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        self.gameButton.isHidden = true
        self.checkGoalStatus()
        
        if userDefaults.value(forKey: "goals") != nil
        {
            self.goalLabel.text = "Current Goal: " + userDefaults.string(forKey: "goals")!
            
        }
        else // no preference was found so we set a default value
        {
            userDefaults.set("0", forKey: "goals")
            userDefaults.synchronize()
        }
        
        if userDefaults.value(forKey: "steps") != nil
        {
            //self.stepLable.text = "Current Goal: \(userDefaults.float(forKey: "steps"))"
        }
        else // no preference was found so we set a default value
        {
            userDefaults.set("0", forKey: "steps")
            userDefaults.synchronize()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return steps.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return steps[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let goal = steps[goalPicker.selectedRow(inComponent: component)]
        currentGaol = steps[goalPicker.selectedRow(inComponent: component)]
        self.userDefaults.set(goal, forKey: "goals")
        checkGoalStatus()
        updateGoalLabel()
        
    }
    
    func updateGoalLabel() {
        self.goalLabel.text = "Current Goal: " + userDefaults.string(forKey: "goals")!
    }
    
    func checkGoalStatus() {
        if stepsToday >= Float(currentGaol)!{
            self.gameButton.isHidden = false
        }
        else{
            self.gameButton.isHidden = true
        }
    }
    
    // MARK: Activity Functions
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // update from this queue (should we use the MAIN queue here??.... )
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: self.handleActivity)
        }
        
    }
    
    
    func handleActivity(_ activity:CMMotionActivity?)->Void{
        // unwrap the activity and disp
        if let unwrappedActivity = activity {
            DispatchQueue.main.async{
                if unwrappedActivity.walking == true {
                    self.movementLable.text = "Movement: Walking"
                }
                else if unwrappedActivity.running == true{
                    self.movementLable.text = "Movement: Running"
                }
                else if unwrappedActivity.cycling == true{
                    self.movementLable.text = "Movement: Cycling"
                }
                else if unwrappedActivity.stationary == true{
                    self.movementLable.text = "Movement: Still"
                }
                else if unwrappedActivity.automotive == true{
                    self.movementLable.text = "Movement: Driving"
                }
                else if unwrappedActivity.unknown == true{
                    self.movementLable.text = "Movement: Uknown"
                }
            }
        }
    }
    
    // MARK: Pedometer Functions
    func startPedometerMonitoring(){
        let lateYesterday = calendar.date(byAdding: .day, value: -2, to: Date())!
        self.yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        //self.today = calendar.date(byAdding: .day, value: 0, to: Date())!
        
        //separate out the handler for better readability
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: yesterday, withHandler: handlePedometer(_:error:))
            pedometer.queryPedometerData(from: lateYesterday, to: yesterday, withHandler: handlePedometerYesterday(_:error:))
            //pedometer.queryPedometerData(from: yesterday, to: today, withHandler: handlePedometerToday(_:error:))
        }
    }
    
    //ped handler
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?)->(){
        if let steps = pedData?.numberOfSteps {
            self.stepsToday = steps.floatValue
        }
    }
    
    //ped handler
    func handlePedometerToday(_ pedData:CMPedometerData?, error:Error?)->(){
        if let steps = pedData?.numberOfSteps {
            self.stepsToday = steps.floatValue
            let s = NSString(format: "%.2f", self.stepsToday)
            self.todaysSteps.text = "Steps Today: " + (s as String)
        }
    }
    
    //ped handler
    func handlePedometerYesterday(_ pedData:CMPedometerData?, error:Error?)->(){
        if let steps = pedData?.numberOfSteps {
            self.stepsYesterday = steps.floatValue
            let s = NSString(format: "%.2f", self.stepsYesterday)
            self.userDefaults.set(stepsYesterday, forKey: "steps")
            self.yesterdaysSteps.text = "Steps Yesterday: " + (s as String)
            self.checkGoalStatus()
        }
    }
    
    
}

