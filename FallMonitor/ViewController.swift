//
//  ViewController.swift
//  FallMonitor
//
//  Created by Daniel Veiga on 19/01/19.
//  Copyright © 2019 Daniel Veiga. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

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
    
    @IBAction func Acionado(_ sender: UISwitch) //Evento do Switch stAcionar
    {
        if stAcionar.isOn                               //Se stAcionar estiver ativado
        {
            self.lblStatus.textColor = UIColor.green    //Seta cor da Label lblStatus para verde
            self.lblStatus.text = "Status ON"           //Seta texto da Label lblStatus para ON
            Acelerometro()                              //Chama funcao Acelerometro
        }
        else                                            //Se stAcionar estiver desativado
        {
            self.lblStatus.textColor = UIColor.red      //Seta cor da Label lblStatus para vermelho
            self.lblStatus.text = "Status OFF"          //Seta texto da Label lblStatus para OFF
            motionManager.stopAccelerometerUpdates()    //Para o Acelerometro
            
            self.EixoX.text = "X: "                     //****************************************
            self.EixoY.text = "Y: "                     //Seta todas as labels para estado inicial
            self.EixoZ.text = "Z: "                     //
            self.Ace.text = "A: "                       //****************************************
        }
    }
    
    func Acelerometro() //Funcao que aciona o acelerometro e atualiza labels dos eixos
    {
        let g = 9.80665                                     //Constante 'g' representa a Aceleracao Gravitacional da Terra
        
        motionManager.accelerometerUpdateInterval = 0.01    //Seta tempo de atualizacao do Acelerometro para 0.01 segundos
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) //Inicia Acelerometro
        {
            (data,erro) in
            if let trueData = data //Executa as linhas abaixo a cada atualizacao de dados
            {
                self.view.reloadInputViews()
                
                let x = (trueData.acceleration.x) * g //*********************************************************************************
                let y = (trueData.acceleration.y) * g //Pega dados dos eixos x, y e z e multiplica pela Aceleracao Gravitacional da Terra
                let z = (trueData.acceleration.z) * g //*********************************************************************************
                
                //*************************************************OBSERVACAO**************************************************************
                //
                //        O Acelerometro dos dispositivos Android retornam valores correspondentes a forca de aceleracao nos eixos x, y e z
                //em metros por segundo incluindo a gravidade (FONTE: https://developer.android.com/guide/topics/sensors/sensors_motion)
                //
                //        Entre tanto os valores retornados pelo Acelerometro dos dispositivos IOS representam o incremento da aceleracao
                //gravitacional nos eixos x, y e z sendo o valor 1 correspondente a aceleracao 9.8 metros por segundo sem considerar a gravidade
                //(FONTE: https://developer.apple.com/documentation/coremotion/getting_raw_accelerometer_events)
                //
                //        Por conta disto foi necessario multiplicar os valores obtidos dos eixos pela aceleracao gravitacional da Terra,
                //representada no codigo pela contante 'g', para que os mesmos sejam equivalentes aos apresentados na aplicacao Android.
                //
                //************************************************************************************************************************
                
                
                self.EixoX.text = "X: \(Double(x))" //*******************************************************
                self.EixoY.text = "Y: \(Double(y))" //Atualiza Labels para os valores dos exios ja calculados
                self.EixoZ.text = "Z: \(Double(z))" //*******************************************************
                
                let ar = (pow(Double(x),2) + pow(Double(y),2) + pow(Double(z),2)).squareRoot() //Calculo da aceleracao do dispositivo
                
                self.Ace.text = "A: \(Double(ar))" //Atualiza Label da aceleracao
                
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
    // .rounded(toPlaces: )
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
