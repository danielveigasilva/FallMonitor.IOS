//
//  ViewController.swift
//  Meu_App
//
//  Created by Daniel Veiga on 19/01/19.
//  Copyright © 2019 Daniel Veiga. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    //Teste de Commit GitHub
    @IBOutlet weak var EixoX: UILabel!
    @IBOutlet weak var EixoY: UILabel!
    @IBOutlet weak var EixoZ: UILabel!
    @IBOutlet weak var Ace: UILabel!
    @IBOutlet weak var stAcionar: UISwitch!
    @IBOutlet weak var lblStatus: UILabel!
    
    var motionManager = CMMotionManager()
    var fallflag = false
    var time1 = Timer()
    var time5 = Timer()
    var segundo1 = 2
    var segundo5 = 5
    
    let max = 28.0
    let min = 4.85
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.stAcionar.isOn = false
        self.lblStatus.text = "Status OFF"
        self.lblStatus.textColor = UIColor.red
    }
    
    @IBAction func Acionado(_ sender: UISwitch)
    {
        if stAcionar.isOn
        {
            self.lblStatus.textColor = UIColor.green
            self.lblStatus.text = "Status ON"
            Acelerometro()
        }
        else
        {
            self.lblStatus.textColor = UIColor.red
            self.lblStatus.text = "Status OFF"
            motionManager.stopAccelerometerUpdates()
            self.EixoX.text = "X: "
            self.EixoY.text = "Y: "
            self.EixoZ.text = "Z: "
            self.Ace.text = "A: "
        }
    }
    
    func Acelerometro()
    {
        let g = 9.80665
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!)
        {
            (data,erro) in
            if let trueData = data
            {
                self.view.reloadInputViews()
                let x = (trueData.acceleration.x) * g
                let y = (trueData.acceleration.y) * g
                let z = (trueData.acceleration.z) * g
                self.EixoX.text = "X: \(Double(x))"
                self.EixoY.text = "Y: \(Double(y))"
                self.EixoZ.text = "Z: \(Double(z))"
                
                let ar = (pow(Double(x),2) + pow(Double(y),2) + pow(Double(z),2)).squareRoot()
                
                self.Ace.text = "A: \(Double(ar))"
                
                if self.fallflag
                {
                    self.verifica(valor: ar)
                }
                else
                {
                    if ar < self.min
                    {
                        self.lblStatus.text = "queda livre"
                        self.fallflag = true
                    }
                    
                    //self.falldetection(valor: ar)
                    
                }
            }
            
        }
    }
    func reset()
    {
        segundo1 = 2
        fallflag = false
        time1.invalidate()
    }
    
    func falldetection(valor aceleracao:Double)
    {
        
        if aceleracao < min
        {
            self.lblStatus.text = "Queda Livre"
            self.fallflag = true
            self.time1 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.AtualizaTempo)), userInfo: nil, repeats: true)
            self.time1.fire()
        }
        
    }
    
    @objc func AtualizaTempo()
    {
        segundo1 = segundo1 - 1
        if (segundo1 == 0)
        {
            self.reset()
        }
    }
    func verifica(valor aceleracao:Double)
    {
        if aceleracao >= max
        {
            self.lblStatus.text = "queda Detectada"
            self.reset()
        }
    }

}
extension Double {
    /// .rounded(toPlaces: )
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
