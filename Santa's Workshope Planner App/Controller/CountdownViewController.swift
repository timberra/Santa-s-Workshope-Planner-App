//
//  ViewController.swift
//  Santa's Workshope Planner App
//
//  Created by liga.griezne on 25/11/2023.
//

import UIKit

class CountdownViewController: UIViewController {
    @IBOutlet weak var countdownLabel: UILabel!
    let targetDate: Date = {
            var components = DateComponents()
            components.year = Calendar.current.component(.year, from: Date())
            components.month = 12
            components.day = 25
            components.hour = 0
            components.minute = 0
            components.second = 0
            return Calendar.current.date(from: components)!
        }()
    var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCountdownLabel()

    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdownLabel), userInfo: nil, repeats: true)
    }
    deinit {
        timer?.invalidate()
    }
    @objc func updateCountdownLabel() {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: targetDate)
        let formattedTime = String(format: "%02dd %02dh %02dm %02ds", components.day ?? 0, components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
        countdownLabel.text = formattedTime
    }
}
