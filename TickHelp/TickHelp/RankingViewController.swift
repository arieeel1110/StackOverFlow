//
//  RankingViewController.swift
//  TickHelp
//
//  Created by Ariel on 4/9/16.
//  Copyright © 2016 Ariel. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func LogOutBtnPressed(sender: UIBarButtonItem) {
        let next = self.storyboard!.instantiateViewControllerWithIdentifier("InitialViewController")
        self.presentViewController(next, animated: true, completion: nil)
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
