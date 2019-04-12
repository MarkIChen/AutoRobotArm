//
//  ViewController.swift
//  AutoRobotArm
//
//  Created by Mark on 2019/3/24.
//  Copyright © 2019 MarkChen. All rights reserved.
//

import UIKit
import CocoaMQTT

class ViewController: UIViewController {
    var mqtt: CocoaMQTT?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMQTT()
        
    }

    @IBAction func setPositionPressed(_ sender: Any) {
        mqtt?.publish("home/test", withString: "testing")
        
        
    }
    @IBAction func SubscribeButtonPressed(_ sender: Any) {
        
        mqtt?.subscribe("home/test")
    }
    
    
    func setupMQTT(){
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: "35.233.174.129", port: 1883)
        mqtt?.autoReconnect = true
        mqtt?.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt?.keepAlive = 60
        mqtt?.delegate = self as? CocoaMQTTDelegate
        if let mqttStatus = mqtt?.connect(){
            print(mqttStatus)
        }
        
        
        
        mqtt?.didSubscribeTopic = {
            mqtt , topic in
            print("I subscribed the robot")
        }
        
        mqtt?.didReceiveMessage = { mqtt, message, id in
            print("Message received in topic \(message.topic) with payload \(message.string!)")
            let messageData = (message.string)?.data(using: .utf8)
            
            if let data = messageData , let result = try? JSONDecoder().decode(JsonProvider.self, from: data) {
                
             
                if let x = result.x , let y = result.y{
                    print("x: \(x)")
                    print("y: \(y)")
                }
            }
            else {
                print("Failed to get the message!")
            }
        }
        
        mqtt?.didPublishMessage = {
            mq, message, a in
//            print(message.string)
        }
        
    }
}

