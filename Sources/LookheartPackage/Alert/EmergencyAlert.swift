import UIKit
import AVFAudio
import AudioToolbox

public class EmergencyAlert: UIViewController {
        
    var audioPlayer: AVAudioPlayer?
    var titleLabel: UILabel?
    var messageLabel: UILabel?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        startAudioPlayer()
        
    }
    
    public func updateText(title: String, message: String) {
        titleLabel?.text = title
        messageLabel?.text = message
    }
    
    @objc func didTapActionButton() {
        audioPlayer?.stop()
        dismiss(animated: true)
    }
    
    func startAudioPlayer() {
        setupEmergencyAudioPlayer("heartAttackSound")
        audioPlayer?.play()
    }
    
    func setupEmergencyAudioPlayer(_ soundFile: String) {
        guard let url = Bundle.main.url(forResource: soundFile, withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 무한 반복 재생
            audioPlayer?.prepareToPlay()
        } catch {
            print("오디오 파일을 로드할 수 없습니다: \(error)")
        }
    }

    private func addViews() {
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // create
        let backgroundView = UIView().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
        }
                
        titleLabel = UILabel().then {
            $0.text = "profile3_emergency".localized()
            $0.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
            $0.textColor = .white
            $0.textAlignment = .center
            $0.backgroundColor = UIColor.MY_RED
        }

        messageLabel = UILabel().then {
            $0.text = "emergencyTxt".localized()
            $0.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
            $0.textColor = UIColor.MY_RED
            $0.textAlignment = .center
            $0.numberOfLines = 3
        }
           
        let actionButton = UIButton().then {
            $0.setTitle("\("ok".localized())", for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            $0.backgroundColor = UIColor.MY_RED
            $0.tintColor = .white
            $0.layer.cornerRadius = 20
            $0.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        }
                
        // addSubview
        view.addSubview(backgroundView)
        backgroundView.addSubview(titleLabel!)
        backgroundView.addSubview(messageLabel!)
        backgroundView.addSubview(actionButton)
        
        
        // makeConstraints
        backgroundView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
            make.width.equalTo(screenWidth / 1.2)
            make.height.equalTo(200)
        }
        
        titleLabel!.snp.makeConstraints { make in
            make.top.left.right.equalTo(backgroundView)
            make.height.equalTo(40)
        }
        
        messageLabel!.snp.makeConstraints { make in
            make.top.equalTo(titleLabel!.snp.bottom).offset(10)
            make.centerX.equalTo(backgroundView)
        }
        
        actionButton.snp.makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.bottom.equalTo(backgroundView).offset(-10)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }

    }
}
