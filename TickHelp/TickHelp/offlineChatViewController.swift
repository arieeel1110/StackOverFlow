//
//  offlineChatViewController.swift
//  TickHelp
//
//  Created by Ariel on 4/9/16.
//  Copyright © 2016 Ariel. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Firebase

class offlineChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {

    @IBOutlet weak var peers: UITableView!
    
    let refAll = Firebase(url: constant.userURL + "/users/")
    var ref = Firebase(url: constant.userURL + "/users/" + constant.uid)

    
    let appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
    var isAdvertising: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        peers.delegate = self
        peers.dataSource = self
        
        appDelagate.mpcManager.delegate = self
        appDelagate.mpcManager.browser.startBrowsingForPeers()
        appDelagate.mpcManager.advertiser.startAdvertisingPeer()
        isAdvertising = true
        
        // Register cell classes
        peers.registerClass(UITableViewCell.self, forCellReuseIdentifier: "idCellPeer")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func visibility(sender: AnyObject) {
        
        let actionSheet = UIAlertController(title: "", message: "Change Visibility", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var actionTitle: String
        if isAdvertising == true {
            actionTitle = "Make me invisible to others"
        }else {
            
            actionTitle = "Make me visible to others"
        }
        
        let visibilityAction: UIAlertAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            if self.isAdvertising == true {
                self.appDelagate.mpcManager.advertiser.stopAdvertisingPeer()
            }else {
                self.appDelagate.mpcManager.advertiser.startAdvertisingPeer()
            }
            
            self.isAdvertising = !self.isAdvertising
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(visibilityAction)
        actionSheet.addAction(cancelAction)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    @IBAction func LogOut(sender: AnyObject) {
        ref.unauth()
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "uid")
        performSegueWithIdentifier("logOutSeg", sender: self)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelagate.mpcManager.foundPeers.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellPeer")! as UITableViewCell
        
        
        refAll.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            print(snapshot.childrenCount) // I got the expected number of items
            
            let enumerator = snapshot.children
            
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                
                let str = rest.value.objectForKey("device") as! String!
                
                
                if (str != nil && str == self.appDelagate.mpcManager.foundPeers[indexPath.row].displayName){
                    print(str)
                    cell.textLabel?.text = rest.value.objectForKey("nickname") as! String!
                }
            }
        })
        
        //cell.textLabel?.text = appDelagate.mpcManager.foundPeers[indexPath.row].displayName
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPeer = appDelagate.mpcManager.foundPeers[indexPath.row] as MCPeerID
        
        //TODO: This function is used to send peer info we are interested in
        appDelagate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelagate.mpcManager.session, withContext: nil, timeout: 20)
        
    }
    
    // MARK: MPCManager delegate method implementation
    func foundPeer() {
        peers.reloadData()
    }
    
    func lostPeer() {
        peers.reloadData()
    }
    
    func invitationWasReceived(fromPeer: String) {
        
        var peerName: String!
        
    
        refAll.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            print(snapshot.childrenCount) // I got the expected number of items
            
            let enumerator = snapshot.children
            
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                
                let str = rest.value.objectForKey("device") as! String!
               
                
                if (str != nil && str == fromPeer){
                    print("hehe")
                    peerName = rest.value.objectForKey("nickname") as! String!
                    peer.uid = rest.value.objectForKey("uid") as! String!
                    peer.nickname = peerName
                    
                    let alert = UIAlertController(title: "", message: "\(peerName) wants to chat with you.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default)  {(alertAction) -> Void in
                        
                        self.appDelagate.mpcManager.invitationHandler(true, self.appDelagate.mpcManager.session)
                    }
                    
                    let declineAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {(alertAction) -> Void in
                        self.appDelagate.mpcManager.invitationHandler!(false,self.appDelagate.mpcManager.session)
                    }
                    
                    alert.addAction(acceptAction)
                    alert.addAction(declineAction)
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock{ () -> Void in
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                    break;
                }
            }
        })
        

        
        //TODO: Currently automatically accepting connection. Need to write code on when to accept/deny connection
        //self.appDelagate.mpcManager.invitationHandler!(true, self.appDelagate.mpcManager.session)
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        NSOperationQueue.mainQueue().addOperationWithBlock{ () -> Void in
            
            print("here")
            self.performSegueWithIdentifier("segueChat", sender: self)}
        
    }
}
