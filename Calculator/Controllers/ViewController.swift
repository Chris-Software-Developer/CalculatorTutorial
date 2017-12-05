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
    
    let numberFormatter = NumberFormatter()
    
    var addButtonPressed: Bool = false
    var minusButtonPressed: Bool = false
    var multiplyButtonPressed: Bool = false
    var divisionButtonPressed: Bool = false
    
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
        self.updateCommasInResultsLabel()
        
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
        
        self.resultsLabel.text = self.resultsLabel.text?.replacingOccurrences(of: ",", with: "")
        
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
        self.updateCommasInResultsLabel()
    }
    
    @IBAction func positiveNegativeButtonPressed(_ sender: UIButton) {
        
        self.resultsLabel.text = self.resultsLabel.text?.replacingOccurrences(of: ",", with: "")
        
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
        self.updateCommasInResultsLabel()
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
        
        // Remove commas.
        
        guard let text = self.resultsLabel.text else {
            print("Couldn't get text from results label.")
            return
        }
        
        let numberNoCommas = text.replacingOccurrences(of: ",", with: "")
        
        guard let value = Double(numberNoCommas) else {
            print("Failed to turn string: \(numberNoCommas) into type Double.")
            return
        }
        
        if self.currentlySelectedOperator == nil && self.value1 == nil {
            
            self.value1 = value
            self.currentlySelectedOperator = operation
            
            return
            
        } else {
            
            guard
                let value1 = self.value1,
                let previouslySelectedOperator = self.currentlySelectedOperator else {
                    fatalError("Error")
            }
            
            // Storing value in a more descriptive name for operations for readability.
            
            let labelValue = value
            
            var result: Double?
            
            switch previouslySelectedOperator {
                
            case "+" :
                result = value1 + labelValue
                self.addButtonPressed = true
                
            case "-" :
                result = value1 - labelValue
                self.minusButtonPressed = true
                
            case "×" :
                result = value1 * labelValue
                self.multiplyButtonPressed = true
                
            case "÷" :
                result = value1 / labelValue
                self.divisionButtonPressed = true
                
            default :
                break
            }
            
            self.highlightButtonPressed()
            
            self.resultsLabel.text = self.resultsLabel.text?.replacingOccurrences(of: ",", with: "")
            
            if let result = result {
                self.value1 = result
                let resultStringNoCommas = result.isWholeNumber ? "\(Int(result))" : "\(result)"
                guard let resultStringWithCommas = self.updateNumberCommas(inString: resultStringNoCommas) else {
                    fatalError("Error: Could not update commas from string \(resultStringNoCommas)")
                }
                self.resultsLabel.text = resultStringWithCommas
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
        
        self.resetButtonPressedStatus()
    }
    
    func resetButtonPressedStatus() {
        
        self.addButtonPressed = false
        self.minusButtonPressed = false
        self.multiplyButtonPressed = false
        self.divisionButtonPressed = false
    }
    
    func highlightButtonPressed() {
        
        if self.addButtonPressed == true {
            self.addButton.backgroundColor = .white
        } else {
            print("Error, could not change addButton background color")
        }
        
        if self.minusButtonPressed == true {
            self.minusButton.backgroundColor = .white
        } else {
            print("Error, could not change minusButton background color")
        }
        
        if self.multiplyButtonPressed == true {
            self.multiplicationButton.backgroundColor = .white
        } else {
            print("Error, could not change multiplicationButton background color")
        }
        
        if self.divisionButtonPressed == true {
            self.divisionButton.backgroundColor = .white
        } else {
            print("Error, could not change divisionButton background color")
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
    
    func updateCommasInResultsLabel() {
        
        if let text = self.resultsLabel.text {
            if let updatedString = self.updateNumberCommas(inString: text) {
                self.resultsLabel.text = updatedString
            }
        }
    }
    
    func updateNumberCommas(inString string: String) -> String? {
        
        // Remove any possibly existing commas for new number (to avoid misplacement of commas for new number).
        
        let noCommasString = string.replacingOccurrences(of: ",", with: "")
        
        guard let numberDouble = Double(noCommasString) else {
            print("Couldn't convert string: \(string) to type of Double.")
            return nil
        }
        
        // Add commas for new number.
        
        self.numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: numberDouble))
        
        return formattedNumber
    }
}
