//
//  MandleViewController.swift
//  Mandelbrot
//
//  Created by ARMANDO BRIONES on 5/31/16.
//  Copyright © 2016 ARMANDO BRIONES. All rights reserved.
//

import UIKit

class MandleViewController: UIViewController, HeavyPainter {

    @IBOutlet weak var paintingActivityIndicator: UIActivityIndicatorView!
    
    var loadingView : UIActivityIndicatorView?
    
    
    
    var pointSize : Int = 1{
        didSet{
            updateUI()
        }
    }
    
    var defaultDomain : Double = 4{
        didSet{
            updateUI()
        }
    }
    
    var defaultOffset : (Double,Double) = (0,0){
        didSet{
            updateUI()
        }
    }
    
    var aspectRatio : CGFloat = 1{
        didSet{
            
        }
    }
    
    var zoomOrigin : CGPoint = CGPoint(x: 0,y: 0){
        didSet{
            print("The user started a zoom rectangle at: \(zoomOrigin.x) \(zoomOrigin.y)")
        }
    }
    
    private var centeredViewDrawn = false
    
    var maxY : Double = 0{
        didSet{
            centeredViewDrawn = true
        }
    }
    
    var xPoints : Int {
        return Int(plotView.bounds.width) / Int(pointSize)
    }
    
    var yPoints : Int {
        return Int(plotView.bounds.height) / Int(pointSize)
    }
    
    var scaleOfUnit : Double = 1//
    
    
    var zoomRectangle : UIView?
    
    
    var xOrigin : Double = -2

    
    
    @IBOutlet weak var plotView: MandleView!{
        didSet{
            
            plotView.ActivityHandler = self
            
            //plotView.addGestureRecognizer(UIPinchGestureRecognizer(target: plotView, action: "scale:"))
            //plotView.addGestureRecognizer(UIPanGestureRecognizer(target: plotView, action: "shiftAxis:" ))
            //plotView.addGestureRecognizer(UIPanGestureRecognizer(target: plotView, action: "selectNewFrame:" ))
        }
    }
    
    func willStartPaintingHeavy() {
        print("Should start spinning")
        paintingActivityIndicator?.startAnimating()
    }
    
    func doneWithHeavyPainting() {
        print("Should stop spinning")
        paintingActivityIndicator?.stopAnimating()
    }
    
    
    var currentImageView : UIImageView?
    
    func updateUI(){
        print("Here we'd replace the current ")
        if let current = self.currentImageView{
            current.removeFromSuperview()
        }
        
        plotView.addSubview(loadingView!)
        loadingView?.startAnimating()
        // Here surround it in a dispatch-queue block
        let quos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(quos, 0)){
            self.currentImageView = UIImageView(frame: self.plotView.bounds)
            self.currentImageView?.userInteractionEnabled = true
            self.currentImageView?.image = self.constructPlot()
            self.currentImageView?.addGestureRecognizer(self.pan)
            
            dispatch_async(dispatch_get_main_queue()){
                self.loadingView?.stopAnimating()
                self.loadingView?.removeFromSuperview()
                self.plotView.addSubview(self.currentImageView!)
            }
        }

    }
    
    
    func constructPlot() -> UIImage{
        UIGraphicsBeginImageContext(plotView.bounds.size)
        
        
        // Draw here...
        
        // To preserve the form when zooming in
        self.aspectRatio = plotView.bounds.width / plotView.bounds.height
        
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

        
        
        let plot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return plot
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let currentView = currentImageView{
            zoomOrigin = (touches.first?.locationInView(currentView))!
            print("Zoom began at \(zoomOrigin.x) \(zoomOrigin.y)")
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
        currentImageView!.addSubview(rectView)
        
        zoomRectangle = rectView
    }
    
    
    
    
    @IBAction func changeZoomBoundaries(sender: UIPanGestureRecognizer) {
        
        print("Pan action happening!")
        
        switch sender.state
        {
        case .Changed:
            
            print("The pan position changed to \(sender.locationInView(currentImageView!).x) \(sender.locationInView(currentImageView!).y)")
            
            if let z = zoomRectangle{
                z.removeFromSuperview()
            }
            
            let endX = sender.locationInView(currentImageView!).x
            addZoomRectangle(endX)
        case .Ended:
            let deltaXInUnitValue = Double(zoomOrigin.x) * scaleOfUnit
            let newX = xOrigin + deltaXInUnitValue
            let deltaYInUnitValue = Double(zoomOrigin.y) * scaleOfUnit
            let newY = maxY - deltaYInUnitValue
            
            xOrigin = newX
            maxY = newY
            
            // In terms of the domain that will just be replaced
            defaultDomain = Double(zoomRectangle!.bounds.width) * scaleOfUnit
        default: ()
        }
        
    }
    
    
    @IBOutlet weak var pan: UIPanGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pan.addTarget(self, action: "changeZoomBoundaries:")
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("The size of the screen is: w = \(plotView.bounds.width), h = \(plotView.bounds.height)")
        loadingView = UIActivityIndicatorView(frame: plotView.bounds)
        loadingView!.color = UIColor.blackColor()
        
        
        updateUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
