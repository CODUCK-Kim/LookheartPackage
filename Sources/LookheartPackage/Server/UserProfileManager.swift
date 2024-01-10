import Foundation

public class UserProfileManager {
    
    public static let shared = UserProfileManager()
    
    private(set) var userProfile: UserProfile? // 싱글톤
    private var guardianPhoneNumbers: [String] = [] // 보호자 번호
    
    public init() { }
    
    // UserProfile
    public func setUserProfile(_ profile: UserProfile) {
        self.userProfile = profile
    }
    
    public func getUserProfile() -> UserProfile {
        return userProfile!
    }
    
    
    // ---------------------------- PROFILE ---------------------------- //
    
    // Email
    public func getEmail() -> String {
        return userProfile?.eq ?? "isEmpty"
    }
    
    // name
    public func setName(_ name: String) {
        userProfile?.eqname = name;
    }
    
    public func getName() -> String {
        return userProfile?.eqname ?? "isEmpty"
    }
    
    // phone
    public func setPhoneNumber(_ phoneNumber: String) {
        userProfile?.userphone = phoneNumber;
    }
    public func getPhoneNumber() -> String {
        return userProfile?.userphone ?? "01012345678"
    }
    
    // birth
    public func setBirthDate(_ birthDate: String) {
        userProfile?.birth = birthDate;
    }
    public func getBirthDate() -> String {
        return userProfile?.birth ?? "isEmpty"
    }
    
    // age
    public func setAge(_ age: String) {
        userProfile?.age = age;
    }
    public func getAge() -> String {
        return userProfile?.age ?? "isEmpty"
    }
    
    // gender
    public func setGender(_ gender: String) {
        userProfile?.sex = gender;
    }
    public func getGender() -> String {
        return userProfile?.sex ?? "isEmpty"
    }
    
    // height
    public func setHeight(_ height: String) {
        userProfile?.height = height;
    }
    public func getHeight() -> String {
        return userProfile?.height ?? "isEmpty"
    }
    
    // weight
    public func setWeight(_ weight: String) {
        userProfile?.weight = weight;
    }
    public func getWeight() -> String {
        return userProfile?.weight ?? "isEmpty"
    }
    
    // sleep time
    public func setBedtime(_ bedtime: Int) {
        userProfile?.sleeptime = bedtime;
    }
    public func getBedtime() -> Int {
        return userProfile?.sleeptime ?? 23
    }
    
    // wake time
    public func setWakeUpTime(_ WakeUpTime: Int) {
        userProfile?.uptime = WakeUpTime;
    }
    public func getWakeUpTime() -> Int {
        return userProfile?.uptime ?? 7
    }
    
    public func getJoinDate() -> String {
        return userProfile?.signupdate ?? "2023-01-01"
    }
    
    // guardianPhoneNumber
    public func setPhoneNumbers(_ numbers: [String]) {
        guardianPhoneNumbers = numbers
    }
    
    public func getPhoneNumbers() -> [String] {
        return guardianPhoneNumbers
    }
    
    // ---------------------------- SETTING ---------------------------- //
    
    // A.bpm
    public func setBpm(_ bpm: Int) {
        userProfile?.bpm = bpm;
    }
    public func getBpm() -> Int {
        return userProfile?.bpm ?? 90
    }
    
    // step
    public func setStep(_ step: Int) {
        userProfile?.step = step;
    }
    public func getStep() -> Int {
        return userProfile?.step ?? 2000
    }
    
    // distance
    public func setDistance(_ distance: Int) {
        userProfile?.distanceKM = distance;
    }
    public func getDistance() -> Int {
        return userProfile?.distanceKM ?? 5
    }
    
    // A.cal
    public func setACal(_ aCal: Int) {
        userProfile?.calexe = aCal;
    }
    public func getACal() -> Int {
        return userProfile?.calexe ?? 500
    }
    
    // total cal
    public func setTCal(_ tCal: Int) {
        userProfile?.cal = tCal;
    }
    public func getTCal() -> Int {
        return userProfile?.cal ?? 500
    }
    
    // ---------------------------- Conversion FLAG ---------------------------- //
    
    public func getConversionFalg() -> Int {
        return userProfile?.alarm_sms ?? 0
    }
    
}
