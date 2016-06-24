//
//  ViewController.swift
//  Mandelbrot
//
//  Created by ARMANDO BRIONES on 5/11/16.
//  Copyright © 2016 ARMANDO BRIONES. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    
    
    @IBOutlet weak var plotView: MandleView!{
        didSet{
            plotView.addGestureRecognizer(UIPinchGestureRecognizer(target: plotView, action: "scale:"))
            //plotView.addGestureRecognizer(UIPanGestureRecognizer(target: plotView, action: "shiftAxis:" ))
            plotView.addGestureRecognizer(UIPanGestureRecognizer(target: plotView, action: "selectNewFrame:" ))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        plotView.zoomOrigin = (touches.first?.locationInView(plotView))!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

