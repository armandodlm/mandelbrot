//
//  MandleView.swift
//  Mandelbrot
//
//  Created by ARMANDO BRIONES on 5/11/16.
//  Copyright © 2016 ARMANDO BRIONES. All rights reserved.
//

import UIKit

class iPoint{
    var real : Double
    var i : Double
    
    init(r: Double, i: Double){
        self.real = r
        self.i = i
    }
    
    var abs : Double {
        return sqrt(pow(self.real,2) + pow(self.i,2))
    }
    
}

func +(lhs: iPoint, rhs: iPoint) -> iPoint{
    return iPoint(r: lhs.real + rhs.real, i: lhs.i + rhs.i)
}

func -(lhs: iPoint, rhs: iPoint) -> iPoint{
    return iPoint(r: lhs.real - rhs.real, i: lhs.i - rhs.i)
}

func *(lhs: iPoint, rhs: iPoint) -> iPoint{
    let real = (lhs.real * rhs.real) - (lhs.i * rhs.i)
    let i = (lhs.i * rhs.real) + (lhs.real * rhs.i)
    return iPoint(r: real, i: i)
}

protocol HeavyPainter : class{
    func willStartPaintingHeavy()
    func doneWithHeavyPainting()
}


class MandleView: UIView {
    
    
    weak var ActivityHandler : HeavyPainter?
    
    var points : [iPoint] = []
    
    var pointSize : Int = 1{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var defaultDomain : Double = 4{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var defaultOffset : (Double,Double) = (0,0){
        didSet{
            setNeedsDisplay()
        }
    }
    
    var aspectRatio : CGFloat = 1{
        didSet{
            
        }
    }
    
    var zoomOrigin : CGPoint = CGPoint(x: 0,y: 0){
        didSet{
                //print("The user started a zoom rectangle")
        }
    }
    
    private var centeredViewDrawn = false
    
    var maxY : Double = 0{
        didSet{
            centeredViewDrawn = true
        }
    }
    
    var xPoints : Int {
        return Int(bounds.width) / Int(pointSize)
    }
    
    
    var yPoints : Int {
        return Int(bounds.height) / Int(pointSize)
    }
    
    var scaleOfUnit : Double = 1// Double(defaultDomain)/Double(xPoints)
    /*
    {
        set{
            self.scaleOfUnit = newValue
        }
        get{
            return Double(defaultDomain)/Double(xPoints)
        }
        
    }*/

    
    var zoomRectangle : UIView?
    
    
    var xOrigin : Double = -2
    //var maxY : Double = 0
    //var scaleOfUnit : Double = 1
    
    
    func scale(gesture: UIPinchGestureRecognizer){
        // Here add the code to zoom in
        // Ask to redraw
        

        switch gesture.state{
        case .Ended: print("Done pinching")
            print("The scale of the pinch was: \(gesture.scale)")
        default: ()
        }
    }
    
    func shiftAxis(gesture: UIPanGestureRecognizer){
        
        
        switch gesture.state{
        case .Ended: print("The center should be shifted by: \(gesture.translationInView(self))")
            let translation = gesture.translationInView(self)
            defaultOffset = (Double(translation.x),Double(translation.y))
        default: ()
        }
    }
    
    func addZoomRectangle(endX : CGFloat){
        //print("Ended at: \(gesture.locationInView(self))")
        
        print("The change in X is: \(endX - zoomOrigin.x)")
        
        let zoomWidth : CGFloat = endX - zoomOrigin.x
        let zoomHeight : CGFloat = zoomWidth / aspectRatio
        
        print("The zoom rectangle would have width: \(zoomWidth) height: \(zoomWidth / aspectRatio) ")
        
        

        
        let zoomRectBounds = CGSize(width: zoomWidth, height: zoomHeight)
        let zoomRect = CGRect(origin: zoomOrigin, size: zoomRectBounds)
        
        let rectView : UIView = UIView(frame: zoomRect)
        rectView.backgroundColor = UIColor.whiteColor()
        rectView.alpha = 0.5
        addSubview(rectView)
        
        zoomRectangle = rectView
    }
    
    
    func selectNewFrame(gesture: UIPanGestureRecognizer){
        
        switch gesture.state{
        case .Began:

            print("Pan began!")
            
        case .Changed:
            
            if let z = zoomRectangle{
                z.removeFromSuperview()
            }
            
            addZoomRectangle(gesture.locationInView(self).x)
            
        case .Ended:

            print("The user is done trying to zoom in")
            //Here calculate what the value in points is
            // Using the current origin we can find out the point of the new origin
            let deltaXInUnitValue = Double(zoomOrigin.x) * scaleOfUnit
            let newX = xOrigin + deltaXInUnitValue
            let deltaYInUnitValue = Double(zoomOrigin.y) * scaleOfUnit
            let newY = maxY - deltaYInUnitValue
            
            xOrigin = newX
            maxY = newY
            
            // In terms of the domain that will just be replaced
            defaultDomain = Double(zoomRectangle!.bounds.width) * scaleOfUnit
            
            //setNeedsDisplay()
            
        default: ()
        }
    }
    
    //var vie : UIImageView = UIImageView(
    
    override func drawRect(rect: CGRect) {
        
        print("DRAW RECT - The size of the screen is: w = \(bounds.width), h = \(bounds.height)")
        /*
        // Determine how big points are (when pointSize = 1 -> points are 1px)
        //let xPoints = Int(bounds.width) / Int(pointSize)
        //let yPoints = Int(bounds.height) / Int(pointSize)
        
        // To preserve the form when zooming in
        self.aspectRatio = self.bounds.width / self.bounds.height
        
        // How wide is each point in the X axis
        self.scaleOfUnit = Double(self.defaultDomain)/Double(self.xPoints)
        
        /*
         print("Width: \(bounds.width) Height: \(bounds.height)")
         print("One dx x dy unit is worth: \(scaleOfUnit) because there are \(xPoints) units in \(bounds.width) pixels")
         print(" X = 0 is located at unit \(xPoints/2)")
         */
        if !self.centeredViewDrawn{
            let maxMinYRange = Double(Double(self.yPoints)/2) * Double(self.scaleOfUnit)
            self.maxY = maxMinYRange
        }
        
        /*
         print("There are \(yPoints) units in the y axis, the y axis goes from: -\(maxMinYRange) to +\(maxMinYRange) ")
         print(" Y = 0 is located at unit \(yPoints/2)")
         */
        /*
         let xDelta = defaultOffset.0 * scaleOfUnit
         let yDelta = defaultOffset.1 * scaleOfUnit
         
         
         print("X delta: \(xDelta), Y delta: \(yDelta)")
         print("Former leftmostX : \(xOrigin)")
         */
        
        //let leftmostX = xOrigin - xDelta
        let leftmostX = self.xOrigin
        let uppermostY = self.maxY
        //xOrigin = leftmostX
        //let uppermostY = maxMinYRange + yDelta
        
        //maxY = uppermostY
        
        let maxIters = 100
        
        for dx in 0...self.xPoints{
            for dy in 0...self.yPoints{
                
                let real = Double( Double(leftmostX) + (Double(dx) * self.scaleOfUnit) )
                let imag = Double( uppermostY - (Double(dy) * self.scaleOfUnit ) )
                let thisPoint = iPoint(r: real, i: imag)
                
                let pointOrigin = CGPoint(x: CGFloat(dx * self.pointSize), y: CGFloat(dy * self.pointSize))
                let rect = CGRect(origin: pointOrigin, size: CGSize(width: self.pointSize, height: self.pointSize))
                let path = UIBezierPath(rect: rect)
                
                if thisPoint.abs <= 2{
                    //UIColor.blackColor().set()
                    //UIColor.whiteColor().set()
                    
                    var iters = 0
                    let c = thisPoint
                    var z = iPoint(r: 0, i: 0)
                    
                    
                    while z.abs <= 2 && iters < maxIters{
                        let newZ = (z * z) + c
                        //c = z
                        z = newZ
                        iters += 1
                    }
                    
                    if iters >= maxIters{
                        UIColor.blackColor().set()
                    }else{
                        UIColor.colorFromScale(iters).set()
                    }
                    
                }else{
                    //UIColor.random.set()
                    UIColor.blackColor().set()
                }
                
                
                
                path.stroke()
                //path.fill()
            }
        }
        */
        
    }
}




private extension UIColor{
    class var random : UIColor{
        switch arc4random() % 7{
        case 0: return UIColor.blueColor()
        case 1: return UIColor.cyanColor()
        case 2: return UIColor.purpleColor()
        case 3: return UIColor.greenColor()
        case 4: return UIColor.redColor()
        case 5: return UIColor.yellowColor()
        case 6: return UIColor.orangeColor()
        default: return UIColor.grayColor()
        }
    }
    
    class func colorFromScale(iterations: Int) -> UIColor{
        switch(iterations % 6){
        case 1: return UIColor.blueColor()
        case 2: return UIColor.cyanColor()
        case 3: return UIColor.greenColor()
        case 4: return UIColor.yellowColor()
        case 5: return UIColor.orangeColor()
        case 6: return UIColor.redColor()
        default: return UIColor.brownColor()
        }
    }
}