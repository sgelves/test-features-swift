//
//  ResultsViewController.swift
//  test tabela
//
//  Created by user155532 on 5/11/19.
//  Copyright © 2019 sgelves. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var resultData: [Result] = []
    let resultArray = ["Resultado um", "Dois", "Informacao aditional do novo resultado que e muito mais longa do que o normal"]
    let resultsService = ResultsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsService.queryResults() { data in
            guard data != nil else {
                return
            }
            self.resultData = data!
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultCellTableViewCell
        let result = resultData[indexPath.row]
        cell.title.text = result.title
        
        if (result.thumbnail != nil) {
            resultsService.queryUrlImage(url: result.thumbnail!) { image in
                cell.thumbnail.image = image
            }
        }
        
        return cell
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
