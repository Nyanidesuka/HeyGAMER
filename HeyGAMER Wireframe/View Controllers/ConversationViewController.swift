//
//  ConversationViewController.swift
//  HeyGAMER
//
//  Created by Haley Jones on 7/10/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    
    //the thing
    var conversation: Conversation?
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversation?.messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
