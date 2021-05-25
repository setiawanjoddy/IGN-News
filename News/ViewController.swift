//
//  ViewController.swift
//  News
//
//  Created by Setiawan Joddy on 25/05/21.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let apiUrl = URL(string : "https://newsapi.org/v2/top-headlines?sources=ign&apiKey="+ApiDetails.apiKey)
    var articles: Array<Dictionary<String,Any>> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "NewsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        loadData()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Networking
    
    func loadData(){
        let session = URLSession.shared.dataTask(with: URLRequest(url : apiUrl!)) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode != 200) {
                    //DIE AND SHOW ERROR MESSAGE
                }
            }
            if let myData = data {
                if let json = try? (JSONSerialization.jsonObject(with: myData, options: []) as! Dictionary<String,Any>) {
                    //PARSE IT
                    if let statusCode = json["status"] as? String {
                        if(statusCode == "ok") {
                            if let articles = json["articles"] as? Array<Dictionary<String,Any>> {
                                self.articles = articles;
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            } else {
                                //ERROR WITH API REQUEST NOT OK
                            }
                        }
                    } else {
                        //ERROR WITH API REQUEST NOT OK
                    }
                } else {
                    print("Error");
                }
            }
        }
        session.resume();
    }
}

//MARK: - UICollectionView
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = articles[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NewsCollectionViewCell
        
        if let title = row["title"] as? String{
            cell.titleLabel.text = title;
        }
        
        if let description = row["description"] as? String{
            cell.subtextLabel.text = description
            
        }
        
        if let urlToImage = row["urlToImage"] as? String{
            cell.newsImageView.sd_setImage(with: URL(string: urlToImage), placeholderImage: UIImage(named: "placeholder"))
        }
        
        if let publishedDate = row["publishedAt"] as? String{
            let dbDateFormatter = DateFormatter()
            dbDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            if let date = dbDateFormatter.date(from: publishedDate){
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                let todaysDate = dateFormatter.string(from: date)
                cell.publishedDateLabel.text = "Published : " + todaysDate
            }
            
            print(publishedDate);
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width
        return CGSize(width: cellWidth, height: cellWidth*0.8)
    }
    
    
}
