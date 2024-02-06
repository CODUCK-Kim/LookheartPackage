import UIKit
import AVFAudio
import AudioToolbox

public class EmergencyAlert: UIViewController {
        
    private var audioPlayer: AVAudioPlayer?
    private var titleLabel: UILabel?
    private var messageLabel: UILabel?
    
    private var alertTitle: String
    private var alertMessage: String
    
    init(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
                
        titleLabel = propCreateUI.label(text: alertTitle, color: .white, size: 18, weight: .heavy).then {
            $0.backgroundColor = UIColor.MY_RED
            $0.textAlignment = .center
        }
        
        messageLabel = propCreateUI.label(text: alertMessage, color: UIColor.MY_RED, size: 16, weight: .heavy).then {
            $0.numberOfLines = 5
        }

        let actionButton = UIButton().then {
            $0.setTitle("\("ok".localized())", for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            $0.backgroundColor = UIColor.MY_RED
            $0.tintColor = .white
            $0.layer.cornerRadius = 10
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
            make.left.right.centerX.equalTo(backgroundView)
        }
        
        actionButton.snp.makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.bottom.equalTo(backgroundView).offset(-10)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }

    }
}
