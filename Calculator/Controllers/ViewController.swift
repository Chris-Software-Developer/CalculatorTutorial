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
    
    var clearSoundEffect: AVAudioPlayer?
    var equalsSoundEffect: AVAudioPlayer?
    var numberSoundEffect: AVAudioPlayer?
    var operationSoundEffect: AVAudioPlayer?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var decimalButton: UIButton!
    @IBOutlet weak var divisionButton: UIButton!
    @IBOutlet weak var multiplicationButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var equalsButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        
        if self.resultsLabel.text != "" {
            self.playClearSoundEffect() }
        
        self.resultsLabel.text = ""
        self.value1 = nil
        self.currentlySelectedOperator = nil
        self.decimalButton.isEnabled = true
        self.zeroButton.isEnabled = true
    }
    
    @IBAction func decimalButtonPressed(_ sender: UIButton) {
        
        if self.resultsLabel.text == "0" || self.resultsLabel.text == "" {
            self.resultsLabel.text = "0" + ""} else {
            self.resultsLabel.text = self.resultsLabel.text! + ""
        }
        
        self.playNumberSoundEffect()
        self.handleNumberPressed(sender)
        self.decimalButton.isEnabled = false
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        if self.resultsLabel.text == "0" || self.value1 == nil {
            self.zeroButton.isEnabled = false
        }
        
        self.playNumberSoundEffect()
        self.handleNumberPressed(sender)
        
        if resultsLabel.text != "0" {
            self.zeroButton.isEnabled = true
        }
    }
    
    @IBAction func operatorPressed(_ sender: UIButton) {
        
        if let operatorString = sender.titleLabel?.text {
            self.handleOperation(operatorString)
        }
        
        if self.resultsLabel.text != "" {
            
            if sender.titleLabel?.text == "=" {
                
                self.playEqualsSoundEffect()
            } else {
                
                self.playOperationSoundEffect()
            }
        }
    }
    
    @IBAction func percentageButtonPressed(_ sender: UIButton) {
        
        if self.resultsLabel.text != "" {
            self.playOperationSoundEffect()
        }
        
        guard
            let valueString = self.resultsLabel.text,
            let value = Double(valueString) else {
                self.resultsLabel.text = ""
                return
        }
        
        let result = value * 0.01
        self.resultsLabel.text = String(result)
    }
    
    @IBAction func positiveNegativeButtonPressed(_ sender: UIButton) {
        
        if self.resultsLabel.text != "" {
            self.playOperationSoundEffect()
        }
        
        guard
            let valueString = self.resultsLabel.text,
            let value = Double(valueString) else {
                self.resultsLabel.text = ""
                return
        }
        
        let result = value * -1
        self.resultsLabel.text = result.isWholeNumber ? "\(Int(result))" : "\(result)"
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultsLabel.minimumScaleFactor = 0.3
        self.resultsLabel.adjustsFontSizeToFitWidth = true
        self.resultsLabel.numberOfLines = 1
    }
    
    // MARK: - Convenience Methods
    
    func handleNumberPressed(_ sender: UIButton) {
        
        if self.resultsLabel.text == "0" {
            if sender.titleLabel?.text == "." {
                self.resultsLabel.text = "0"
            } else {
                
                self.resultsLabel.text = ""
            }
        }
        
        if self.operatorJustPressed == true {
            if sender.titleLabel?.text == "." {
                self.resultsLabel.text = "0" + ""
            } else {
                self.resultsLabel.text = "" }
            operatorJustPressed = false
        }
        
        if let numberString = sender.titleLabel?.text {
            self.resultsLabel.text = self.resultsLabel.text! + numberString
        }
    }
    
    func handleOperation(_ operation: String) {
        
        self.decimalButton.isEnabled = true
        self.operatorJustPressed = true
        
        guard
            let labelText = self.resultsLabel.text,
            let value = Double(labelText) else {
                return
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
    
    func playClearSoundEffect() {
        
        guard let path = Bundle.main.path(forResource: "clear", ofType: "mp3") else {
            fatalError("Couldn't find the path for clear.mp3")
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            self.clearSoundEffect = try AVAudioPlayer(contentsOf: url)
            self.clearSoundEffect!.play()
        } catch {
            print("Failed to instantiate audio player. Error: \(error.localizedDescription)")
        }
    }
    
    func playEqualsSoundEffect() {
        
        guard let path = Bundle.main.path(forResource: "equals", ofType: "aif") else {
            fatalError("Couldn't find the path for equals.aif")
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            self.equalsSoundEffect = try AVAudioPlayer(contentsOf: url)
            self.equalsSoundEffect!.play()
        } catch {
            print("Failed to instantiate audio player. Error: \(error.localizedDescription)")
        }
    }
    
    func playNumberSoundEffect() {
        
        guard let path = Bundle.main.path(forResource: "number", ofType: "aif") else {
            fatalError("Couldn't find the path for number.aif")
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            self.numberSoundEffect = try AVAudioPlayer(contentsOf: url)
            self.numberSoundEffect!.play()
        } catch {
            print("Failed to instantiate audio player. Error: \(error.localizedDescription)")
        }
    }
    
    func playOperationSoundEffect() {
        
        guard let path = Bundle.main.path(forResource: "operation", ofType: "mp3") else {
            fatalError("Couldn't find the path for operation.mp3")
        }
        let url = URL(fileURLWithPath: path)
        
        do {
            self.operationSoundEffect = try AVAudioPlayer(contentsOf: url)
            self.operationSoundEffect!.play()
        } catch {
            print("Failed to instantiate audio player. Error: \(error.localizedDescription)")
        }
    }
    
    func formatNumber() {
        
        if let value = self.value1 {
            NumberFormatter.localizedString(from: NSNumber(value: value), number: NumberFormatter.Style.decimal)
        }
    }
}
