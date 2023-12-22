//
//  ViewController.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/21.
//

import UIKit

class ViewController: UIViewController {

    private let model = ViewControllerViewModel()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.coindatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let data = model.getData(at: indexPath.row)
        cell.textLabel?.text = data.currency
        cell.detailTextLabel?.text = data.price
        return cell
    }
    

}
