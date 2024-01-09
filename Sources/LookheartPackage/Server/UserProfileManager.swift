import Foundation

open class UserProfileManager {
    
    public static let shared = UserProfileManager()
    
    private(set) var userProfile: UserProfile? // 싱글톤
    private var guardianPhoneNumbers: [String] = [] // 보호자 번호
    
    public init() { }
    
    // UserProfile
    func setUserProfile(_ profile: UserProfile) {
        self.userProfile = profile
    }
    
    func getUserProfile() -> UserProfile {
        return userProfile!
    }
    
    
    // ---------------------------- PROFILE ---------------------------- //
    
    // Email
    func getEmail() -> String {
        return userProfile?.eq ?? "isEmpty"
    }
    
    // name
    func setName(_ name: String) {
        userProfile?.eqname = name;
    }
    func getName() -> String {
        return userProfile?.eqname ?? "isEmpty"
    }
    
    // phone
    func setPhoneNumber(_ phoneNumber: String) {
        userProfile?.userphone = phoneNumber;
    }
    func getPhoneNumber() -> String {
        return userProfile?.userphone ?? "01012345678"
    }
    
    // birth
    func setBirthDate(_ birthDate: String) {
        userProfile?.birth = birthDate;
    }
    func getBirthDate() -> String {
        return userProfile?.birth ?? "isEmpty"
    }
    
    // age
    func setAge(_ age: String) {
        userProfile?.age = age;
    }
    func getAge() -> String {
        return userProfile?.age ?? "isEmpty"
    }
    
    // gender
    func setGender(_ gender: String) {
        userProfile?.sex = gender;
    }
    func getGender() -> String {
        return userProfile?.sex ?? "isEmpty"
    }
    
    // height
    func setHeight(_ height: String) {
        userProfile?.height = height;
    }
    func getHeight() -> String {
        return userProfile?.height ?? "isEmpty"
    }
    
    // weight
    func setWeight(_ weight: String) {
        userProfile?.weight = weight;
    }
    func getWeight() -> String {
        return userProfile?.weight ?? "isEmpty"
    }
    
    // sleep time
    func setBedtime(_ bedtime: Int) {
        userProfile?.sleeptime = bedtime;
    }
    func getBedtime() -> Int {
        return userProfile?.sleeptime ?? 23
    }
    
    // wake time
    func setWakeUpTime(_ WakeUpTime: Int) {
        userProfile?.uptime = WakeUpTime;
    }
    func getWakeUpTime() -> Int {
        return userProfile?.uptime ?? 7
    }
    
    func getJoinDate() -> String {
        return userProfile?.signupdate ?? "2023-01-01"
    }
    
    // ---------------------------- PROFILE ---------------------------- //
    
    // A.bpm
    func setBpm(_ bpm: Int) {
        userProfile?.bpm = bpm;
    }
    func getBpm() -> Int {
        return userProfile?.bpm ?? 90
    }
    
    // step
    func setStep(_ step: Int) {
        userProfile?.step = step;
    }
    func getStep() -> Int {
        return userProfile?.step ?? 2000
    }
    
    // distance
    func setDistance(_ distance: Int) {
        userProfile?.distanceKM = distance;
    }
    func getDistance() -> Int {
        return userProfile?.distanceKM ?? 5
    }
    
    // A.cal
    func setACal(_ aCal: Int) {
        userProfile?.calexe = aCal;
    }
    func getACal() -> Int {
        return userProfile?.calexe ?? 500
    }
    
    // total cal
    func setTCal(_ tCal: Int) {
        userProfile?.cal = tCal;
    }
    func getTCal() -> Int {
        return userProfile?.cal ?? 500
    }
    
    // ---------------------------- SETTING ---------------------------- //
    
    // guardianPhoneNumber
    func setPhoneNumbers(_ numbers: [String]) {
        guardianPhoneNumbers = numbers
    }
    
    func getPhoneNumbers() -> [String] {
        return guardianPhoneNumbers
    }

}
