//
//  CoinDetailsViewController.swift
//  Ethreum
//
//  Created by chawapon.kiatpravee on 14/8/2566 BE.
//

import UIKit
class CoinDetailsViewController: UIViewController {
    @IBOutlet weak var prevPriceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var prevMCapLabel: UILabel!
    @IBOutlet weak var mCapLabel: UILabel!
    @IBOutlet weak var mCapChangeLabel: UILabel!
    @IBOutlet weak var prevVolLabel: UILabel!
    @IBOutlet weak var volLabel: UILabel!
    @IBOutlet weak var volChangeLabel: UILabel!
    var coinId: String?
    let coinInfoRequestString = "https://api.coingecko.com/api/v3/coins/%@/history?date=%@"
    var yesterdayData: CoinInfoModel.PriceModel?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        getCoinInfo()
    }
    
    func getDateString() -> (String ,String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let todayString = dateFormatter.string(from: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayString = dateFormatter.string(from: yesterday)
        return (yesterdayString, todayString)
        
    }
    
    func getCoinInfo() {
        let (yesterday, today) = getDateString()
        let yesterdayRequest = URLRequest(url: URL(string: String(format: coinInfoRequestString, coinId!, yesterday))!)
        let yesterdayTask = URLSession.shared.dataTask(with: yesterdayRequest) { data, _, _ in
            if let data = data {
                do {
                    let decoder = try JSONDecoder().decode(CoinInfoModel.self, from: data)
                    DispatchQueue.main.sync {
                        self.prevPriceLabel.text = self.getFormattedNumberString(decoder.marketData?.price?.usd)
                        self.prevMCapLabel.text = self.getFormattedNumberString(decoder.marketData?.cap?.usd)
                        self.prevVolLabel.text = self.getFormattedNumberString(decoder.marketData?.volume?.usd)
                        self.yesterdayData = decoder.marketData
                        self.getTodayInfo(todayDateString: today)
                    }
                }
                catch {
                    print(error)
                }
            }
        }
        yesterdayTask.resume()
    }
    
    func getTodayInfo(todayDateString: String) {
        let todayRequest = URLRequest(url: URL(string: String(format: coinInfoRequestString, coinId!, todayDateString))!)
        let todayTask = URLSession.shared.dataTask(with: todayRequest) { data, _, _ in
            if let data = data {
                do {
                    let decoder = try JSONDecoder().decode(CoinInfoModel.self, from: data)
                    DispatchQueue.main.sync {
                        self.priceLabel.text = self.getFormattedNumberString(decoder.marketData?.price?.usd)
                        self.mCapLabel.text = self.getFormattedNumberString(decoder.marketData?.cap?.usd)
                        self.volLabel.text = self.getFormattedNumberString(decoder.marketData?.volume?.usd)
                        self.priceChangeLabel.text = self.getPercentChange(label: self.priceChangeLabel, firstPrice: self.yesterdayData?.price?.usd, secondPrice: decoder.marketData?.price?.usd)
                        self.mCapChangeLabel.text = self.getPercentChange(label: self.mCapChangeLabel, firstPrice: self.yesterdayData?.cap?.usd, secondPrice: decoder.marketData?.cap?.usd)
                        self.volChangeLabel.text = self.getPercentChange(label: self.volChangeLabel, firstPrice: self.yesterdayData?.volume?.usd, secondPrice: decoder.marketData?.volume?.usd)
                    }
                }
                catch {
                    print(error)
                }
            }
        }
        todayTask.resume()
    }
    
    func getFormattedNumberString(_ number: Double?, isPercent: Bool = false) -> String {
        guard let number = number else { return "N/A" }
        let outputSymbol = isPercent ? "%%" : "$"
        return String(format: "%.2f \(outputSymbol)", number)
    }
    
    func getPercentChange(label: UILabel, firstPrice: Double?, secondPrice: Double?) -> String {
        guard let firstPrice = firstPrice, let secondPrice = secondPrice, firstPrice > 0 else {
            return "N/A"
        }
        let result = ((secondPrice - firstPrice) / firstPrice) * 100
        var prefix = ""
        if result > 0 {
            prefix = "+"
            label.textColor = .green
        } else if result < 0 {
            label.textColor = .red
        }
        return "\(prefix)\(getFormattedNumberString(result, isPercent: true))"
    }
}

struct CoinInfoModel: Codable {
    let marketData: PriceModel?
    
    enum CodingKeys: String, CodingKey {
        case marketData = "market_data"
    }
    
    struct PriceModel: Codable {
        let price: Data?
        let cap: Data?
        let volume: Data?
        
        enum CodingKeys: String, CodingKey {
            case price = "current_price"
            case cap = "market_cap"
            case volume = "total_volume"
        }
        
        struct Data: Codable {
            let usd: Double?
        }
    }
}
