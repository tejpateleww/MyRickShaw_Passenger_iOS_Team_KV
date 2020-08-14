//
//  RegistrationContainerViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 26/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import CHIPageControl

class RegistrationContainerViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var pageControl: CHIPageControlJaloro!
    @IBOutlet weak var scrollObject: UIScrollView!
    @IBOutlet weak var ConstraintOfBottomOfCloseImage: NSLayoutConstraint!
    
    @IBOutlet weak var imgClose: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollObject.delegate = self
        pageControl.tintColor = UIColor.gray
        
        if (DeviceType.IS_IPHONE_X) {
            
            let newConstraint = self.ConstraintOfBottomOfCloseImage.constraintWithMultiplier(6)
            self.view!.removeConstraint(self.ConstraintOfBottomOfCloseImage)
//             self.imgClose!.addConstraint(self.ConstraintOfBottomOfCloseImage = newConstraint as NSLayoutConstraint)
            ConstraintOfBottomOfCloseImage = newConstraint
            self.view!.addConstraint(ConstraintOfBottomOfCloseImage)
            self.view!.layoutIfNeeded()
          
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        UIApplication.shared.isStatusBarHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
   
    
    @IBAction func btnBackAction(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//        let currentPage = scrollView.contentOffset.x / scrollView.frame.size.width
//        self.pageControl.set(progress: Int(0), animated: true)
        let currentPage = self.scrollObject.contentOffset.x / self.scrollObject.frame.size.width

        if (currentPage == 0)
        {
              self.navigationController?.popViewController(animated: true)
        }
        else if (currentPage == 1){
            self.scrollObject.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.pageControl.set(progress: 0, animated: true)
        }
        else
        {
            self.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
            self.pageControl.set(progress: 0, animated: true)
        }

    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentPage = scrollView.contentOffset.x / scrollView.frame.size.width
        self.pageControl.set(progress: Int(currentPage), animated: true)

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

