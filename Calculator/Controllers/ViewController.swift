//
//  ViewController.swift
//  Calculator
//
//  Created by Christopher Smith on 11/21/17.
//  Copyright © 2017 Christopher Smith. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: Properties
    
    var value1: Double?
    var currentlySelectedOperator: String?
    var operatorJustPressed = false
    
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    // MARK: IBOutlets
    
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var decimalButton: UIButton!
    
    // MARK: IBActions
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        
        self.resultsLabel.text = ""
        self.value1 = nil
        self.currentlySelectedOperator = nil
        self.decimalButton.isEnabled = true
    }
    
    @IBAction func decimalButtonPressed(_ sender: UIButton) {
        
        self.handleNumberPressed(sender)
        self.decimalButton.isEnabled = false
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        self.handleNumberPressed(sender)
        
   
        
        
    }
    
    @IBAction func operatorPressed(_ sender: UIButton) {
        
        if let operatorString = sender.titleLabel?.text {
            self.handleOperation(operatorString)
        }
    }
    
    @IBAction func percentageButtonPressed(_ sender: UIButton) {
        
        guard
            let valueString = self.resultsLabel.text,
            let value = Double(valueString) else {
                self.resultsLabel.text = "Error"
                return
        }
        
        let result = value * 0.01
        self.resultsLabel.text = String(result)
    }
    
    @IBAction func positiveNegativeButtonPressed(_ sender: UIButton) {
        
        guard
            let valueString = self.resultsLabel.text,
            let value = Double(valueString) else {
                self.resultsLabel.text = "Error"
                return
        }
        
        let result = value * -1
        self.resultsLabel.text = result.isWholeNumber ? "\(Int(result))" : "\(result)"
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultsLabel.minimumScaleFactor = 0.3
        self.resultsLabel.adjustsFontSizeToFitWidth = true
        self.resultsLabel.numberOfLines = 1
        
 /*       let numberPressedSound = Bundle.main.path(forResource: "number", ofType: ".aif")
        
        do {
            
            try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: numberPressedSound!))
        }
        catch {
            print("Error")
            
        }  */
    }
    
    // MARK: Convenience Methods
    
    func handleNumberPressed(_ sender: UIButton) {
        
        if self.operatorJustPressed == true {
            self.resultsLabel.text = ""
            operatorJustPressed = false
        }
        
        if let numberString = sender.titleLabel?.text  {
            self.resultsLabel.text = self.resultsLabel.text! + numberString
        }
    }
    
    func handleOperation(_ operation: String) {
        
        self.decimalButton.isEnabled = true
        self.operatorJustPressed = true
        
        guard
            let labelText = self.resultsLabel.text,
            let value = Double(labelText) else {
                fatalError("Error")
        }
        
        if self.currentlySelectedOperator == nil && self.value1 == nil {
            
            self.value1 = value
            self.currentlySelectedOperator = operation
            
            return
            
        } else {
            
            guard
                let value1 = self.value1,
                let value2String = self.resultsLabel.text,
                let value2 = Double(value2String),
                let previouslySelectedOperator = self.currentlySelectedOperator else {
                    fatalError("Error")
            }
            
            var result: Double?
            
            switch previouslySelectedOperator {
                
            case "+" :
                result = value1 + value2
                
            case "-" :
                result = value1 - value2
                
            case "×" :
                result = value1 * value2
                
            case "÷" :
                result = value1 / value2
                
            default :
                break
            }
            
            if let result = result {
                self.value1 = result
                self.resultsLabel.text = result.isWholeNumber ? "\(Int(result))" : "\(result)"
            }
        }
        
        if operation == "=" {
            self.currentlySelectedOperator = nil
            self.value1 = nil
            self.decimalButton.isEnabled = true
        }
            
        else {
            currentlySelectedOperator = operation
        }
    }
}
