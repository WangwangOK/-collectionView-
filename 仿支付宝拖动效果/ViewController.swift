//
//  ViewController.swift
//  仿支付宝拖动效果
//
//  Created by Vivien on 15/7/28.
//  Copyright (c) 2015年 wangwang. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var sourceIndex:NSIndexPath!
    
    var snapshot:UIView!
    
    
    var dataSorce:NSMutableArray = {
        return ["app-icon-60_18","app-icon-60_19","app-icon-60_20","app-icon-60_21","app-icon-60_22","app-icon-60_23","app-icon-60_24","app-icon-60_25"]
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.collectionView.registerNib(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cellID")
        var longPressGesture = UILongPressGestureRecognizer(target: self, action: "onLongPressInCollectionView:")
        self.collectionView.addGestureRecognizer(longPressGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func onLongPressInCollectionView(gesture:UILongPressGestureRecognizer){
        
        var state:UIGestureRecognizerState = gesture.state
        
        var location = gesture.locationInView(self.collectionView)
        
        var indexPath = self.collectionView.indexPathForItemAtPoint(location)
        
        switch state{
            
        case UIGestureRecognizerState.Began:
            if(indexPath == nil){
                return
            }
            sourceIndex = indexPath!
            var cell:CollectionViewCell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! CollectionViewCell
            snapshot = onSnapshotFromView(cell)
            snapshot.alpha = 0.0
            snapshot.center = cell.center;
            self.collectionView.addSubview(snapshot)
            var center = cell.center
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                center.y = location.y
                self.snapshot.center = center
                self.snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                self.snapshot.alpha = 0.98;
                cell.alpha = 0.0;
                }, completion: { (Bool) -> Void in
                    cell.hidden = true
            })
            print("Begin")
            break
        case UIGestureRecognizerState.Changed:
            snapshot.center = location
            
            if (indexPath != nil && indexPath!.isEqual(sourceIndex) == false) {
                self.dataSorce.exchangeObjectAtIndex(indexPath!.row, withObjectAtIndex: sourceIndex.row)
                self.collectionView.moveItemAtIndexPath(sourceIndex, toIndexPath: indexPath!)
                sourceIndex = indexPath!
            }
            break;
        default:
            // Clean up.
            var cells = self.collectionView.cellForItemAtIndexPath(sourceIndex)
            if let cell = self.collectionView.cellForItemAtIndexPath(sourceIndex){
                cell.hidden = false
                cell.alpha = 0.0
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.snapshot.center = cell.center
                    self.snapshot.transform = CGAffineTransformIdentity
                    self.snapshot.alpha = 0.0
                    cell.alpha = 1.0
                    }, completion: { (Bool) -> Void in
                        self.snapshot.removeFromSuperview()
                })
            }
            break
        }
    }
    
    //MARK: - CollectionView Delegate And DataSource -
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSorce.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellID", forIndexPath: indexPath) as? CollectionViewCell
        if(cell == nil){
            cell = NSBundle.mainBundle().loadNibNamed("CollectionViewCell", owner: self, options: nil).first as? CollectionViewCell
        }
        cell!.imageView.image = UIImage(named: dataSorce[indexPath.row] as! String)
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(80, 80)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("点击")
    }
    
    //MARK: - 截屏 -
    private func onSnapshotFromView(inputView:UIView) -> UIView{
        // Make an image from the input view.
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0);
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext())
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        var snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false;
        snapshot.layer.cornerRadius = 0.0;
        snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
        snapshot.layer.shadowRadius = 5.0;
        snapshot.layer.shadowOpacity = 0.4;
        return snapshot;
    }
}

