//
//  MainViewController.swift
//  missions
//
//  Created by Umar Qattan on 10/6/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit
import SwiftUI


enum Stance: Float {
    case left = -1
    case semiLeft = -0.5
    case neutral = 0.0
    case semiRight = 0.5
    case right = 1
    
    
    static func stanceForValue(_ value: Float) -> Stance {
        switch value {
        case -1.1 ..< -0.75:
            return .left
        case -0.75 ..< -0.25:
            return .semiLeft
        case -0.25 ..< 0.25:
            return .neutral
        case 0.25 ..< 0.75:
            return .semiRight
        case 0.75 ..< 1.1:
            return .right
        default: return .neutral
        }
    }
    
    var valueForStance: Float {
        switch self {
        case .left: return -1
        case .semiLeft: return -0.5
        case .neutral: return 0
        case .semiRight: return 0.5
        case .right: return 1
        }
    }
    
    static func stanceFromString(_ string: String) -> Stance {
        switch string {
        case "left": return .left
        case "semi_left": return .semiLeft
        case "neutral": return .neutral
        case "semi_right": return .semiRight
        case "right": return .right
        default: return .neutral
        }
    }
    
    var stanceString: String {
        switch self {
        case .left: return "left"
        case .semiLeft: return "semi_left"
        case .neutral: return "neutral"
        case .semiRight: return "semi_right"
        case .right: return "right"
        }
    }
    
    
    
    var stanceLabelString: String {
        switch self {
        case .left: return "Left"
        case .semiLeft: return "Semi Left"
        case .neutral: return "Neutral"
        case .semiRight: return "Semi Right"
        case .right: return "Right"
        }
    }
}

enum Activity: String {
    case walk = "walk"
    case run = "run"
    case squat = "squat"
    case stand = "stand"
    
    var activityString: String {
        return self.rawValue.capitalized
    }
    
}


@available (iOS 13, *)
enum SessionState: Int {
    case stop
    case record
    
    var image: UIImage? {
        switch self {
        case .stop:
            return UIImage(systemName: "circle.fill")
        case .record:
            return UIImage(systemName: "square.fill")
        }
    }
    
    var toggle: SessionState {
        switch self {
        case .stop:
            return .record
            
        case .record:
            return .stop
        }
    }
}

@available (iOS 13, *)
enum PlaybackState: Int {
    case pause
    case play
    
    var image: UIImage? {
        switch self {
        case .pause:
            return UIImage(systemName: "play.fill")
        case .play:
            return UIImage(systemName: "pause.fill")
        }
    }
    
    var toggle: PlaybackState {
        switch self {
        case .pause:
            return .play
        case .play:
            return .pause
        }
    }
    
    var actualImage: UIImage? {
        switch self {
        case .play:
            return UIImage(systemName: "play.fill")
        case .pause:
            return UIImage(systemName: "pause.fill")
        }
    }
}


@available (iOS 13, *)
class MainViewController: UIViewController {

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var stanceLabel: UILabel!
    @IBOutlet weak var stanceSlider: UISlider!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var backwardButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    private var sessionState: SessionState = .stop
    private var playbackState: PlaybackState = .pause
    private var timer: Timer!
    private var sessions: [Session] = []
    private var currentSession: Session!
    private var currentSensors: [Sensor] = []
    private var currentTimes: [Date] = []
    private var currentStances: [String] = []
    private var currentActivities: [String] = []
    private var currentValues: [Float] = []
    private var currentActivity: Activity = .stand
    private var currentStance: Stance = .neutral
    private var currentlySelectedIndexPath: IndexPath?
    private var cellModels: [RecordingTableViewCellModel] = []
    
    private var leftValues: [Int] = []
    private var rightValues: [Int] = []
    
    @IBOutlet weak var recordButton: UIImageView!
    @IBOutlet weak var playbackToolbar: UIToolbar!
    @IBOutlet weak var missionsView: MissionsView!
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.recordButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRecordButtonTapped(_:))))
        
        
        self.addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.sessions = self.getSessions() ?? []
        self.cellModels = self.getCellModels()
    }
    
    @objc func onRecordButtonTapped(_ sender: Any) {
        print("Tapped Record")
        
        self.sessionState = self.sessionState.toggle
        self.recordButton.image = self.sessionState.image
        
        if self.sessionState == .record {
            self.stanceSlider.isEnabled = false
        }
        
        if self.sessionState == .stop {
            self.saveNewSession()
            self.tableView.reloadData()
            self.stanceSlider.isEnabled = true
        }
    }
    
    private func saveNewSession() {
        self.currentSession = Session(sensors: self.currentSensors, times: self.currentTimes, stances: self.currentStances, activities: self.currentActivities, values: self.currentValues)
        self.sessions.append(self.currentSession)
        self.appDelegate?.saveSessions(self.sessions)
        self.currentSensors = []
        self.currentTimes = []
        self.currentStances = []
        self.currentActivities = []
        self.currentValues = []
        self.cellModels = self.getCellModels()
    }
    
    @IBAction func onPlay(_ sender: UIBarButtonItem) {
        self.playbackState = self.playbackState.toggle
        self.playButton.image = self.playbackState.image
        
        if let indexPath = self.currentlySelectedIndexPath, self.playbackState == .play {
            self.recordButton.isUserInteractionEnabled = false
            let session = self.sessions[indexPath.row]
            
            for (i, sensor) in session.sensors.enumerated() {
                self.appDelegate?.delay(0.5 * Double(i)/Double(session.sensors.count), closure: {
                    print("Delay: \(0.5 * Double(i))")
                    self.missionsView.updateLeftSensors(values: sensor.leftValues())
                    self.missionsView.updateRightSensors(values: sensor.rightValues())
                    // toggle the record and playback buttons
                    // when arriving at the last sensor array values
                    if i == session.sensors.count - 1 {
                        self.playbackState = self.playbackState.toggle
                        self.playButton.image = self.playbackState.image
                        self.recordButton.isUserInteractionEnabled = true
                    }
                })
            }
        } else if self.playbackState == .pause {
        
        }
    }
    
    @IBAction func onRewind(_ sender: UIBarButtonItem) {
    }
    
    
    @IBAction func onForward(_ sender: UIBarButtonItem) {
    }

    @IBAction func onStanceChanged(_ sender: UISlider) {
        
        self.currentStance = Stance.stanceForValue(sender.value)
        self.stanceLabel.text = self.currentStance.stanceLabelString
        sender.setValue(self.currentStance.valueForStance, animated: false)
    }
    
    
    @IBAction func onShareTapped(_ sender: Any) {
        let fileURL = Disk.getURL(for: .documents)
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

        self.present(activityViewController, animated: true, completion: nil)
    }
    
}

@available(iOS 13, *)
extension MainViewController {
    func addObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(update(_:)), name: NSNotification.Name(rawValue: BLEDeviceSide.left.rawValue), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(update(_:)), name: NSNotification.Name(rawValue: BLEDeviceSide.right.rawValue), object: nil)
        }
    
    @objc func update(_ notification: Notification) {
        
        guard
            let userInfo = notification.userInfo,
            let values = userInfo["values"] as? [Int]
        else { return }
        
        switch notification.name.rawValue {
        case BLEDeviceSide.left.rawValue:
            self.missionsView.updateLeftSensors(values: values)
            self.leftValues = values
        case BLEDeviceSide.right.rawValue:
            self.missionsView.updateRightSensors(values: values)
            self.rightValues = values
        default: break
        }
        
        if self.sessionState == .record {
            let (sensor, time, stance, activity, value) = self.getSessionData(leftValues: self.leftValues, rightValues: self.rightValues)
            self.currentSensors.append(sensor)
            self.currentTimes.append(time)
            self.currentStances.append(stance)
            self.currentActivities.append(activity)
            self.currentValues.append(value)
        }
        
    }
    
    func getSessionData(leftValues: [Int], rightValues: [Int]) -> (Sensor, Date, String, String, Float) {
        guard leftValues.count == 6, rightValues.count == 6 else {
            let time = Date.getTime()
            return (
                Sensor(values: [Int](repeating: 0, count: 12)),
                time,
                self.currentStance.stanceString,
                self.currentActivity.activityString,
                0
            )
        }
        
        var extendedValues = leftValues
        extendedValues.append(contentsOf: rightValues)
        let sensor = Sensor(values: extendedValues)
        let time = Date.getTime()
        let stance = self.currentStance.stanceString
        let activity = self.currentActivity.activityString
        let value = self.currentStance.valueForStance
        
        return (sensor, time, stance, activity, value)
    }
    
    func getSessions() -> [Session]? {
        return self.appDelegate?.retrieveSessions()
    }
    
    func saveSessions() {
        
    }
    
    func getCellModels() -> [RecordingTableViewCellModel] {
        var cellModels = [RecordingTableViewCellModel]()
        for (i, session) in self.sessions.enumerated() {
            cellModels.append(
                RecordingTableViewCellModel(
                    title: "Session \(i)",
                    date: session.timeCreated(),
                    time: session.duration().toTime(),
                    description: "\(session.activities.first?.capitalized ?? "Stand") \(Stance.stanceFromString(session.stances.first ?? "neutral").stanceLabelString)"
                )
            )
        }
        
        return cellModels
        
    }
    
}

@available(iOS 13, *)
extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingTableViewCellId", for: indexPath) as! RecordingTableViewCell
        
        cell.bind(with: self.cellModels[indexPath.row])
        
        return cell
    }
}

@available(iOS 13, *)
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.sessions.remove(at: indexPath.row)
            self.cellModels.remove(at: indexPath.row)
            self.appDelegate?.clearFile(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        guard indexPath != self.currentlySelectedIndexPath else {
            self.currentlySelectedIndexPath = nil
            self.enableToolBar(false)
            return
        }
        
        self.currentlySelectedIndexPath = indexPath
        self.enableToolBar(true)
        print(self.sessions[indexPath.row].description())
    }
    
    func enableToolBar(_ enable: Bool) {
        if !enable {
            self.playbackState = .pause
            
            self.playButton.image = self.playbackState.image
        }
        self.playButton.isEnabled = enable
        self.forwardButton.isEnabled = enable
        self.backwardButton.isEnabled = enable
    }
    
    
}

