

let ECG_MAX_ARRAY = 500
let ECG_DATA_MAX = 140

let PrevDateKey = "prevDate"
let PrevHourKey = "prevHour"

let ARR_TAG = 1, ARR_STATE = "arr"
let EMERGENCY_TAG = 2
let NONCONTACT_TAG = 3
let MYO_TAG = 4
let FAST_ARR_TAG = 5, FAST_ARR_STATE = "fast"
let SLOW_ARR_TAG = 6, SLOW_ARR_STATE = "slow"
let HEAVY_ARR_TAG = 7, HEAVY_ARR_STATE = "irregular"

let ArrState:[Int : String] = [ARR_TAG : ARR_STATE, FAST_ARR_TAG : FAST_ARR_STATE, SLOW_ARR_TAG : SLOW_ARR_STATE, HEAVY_ARR_TAG : HEAVY_ARR_STATE]

var propEmail : String {
    get {
        return UserProfileManager.shared.email
    }
}


var propCurrentTime : String {
    get {
        return MyDateTime.shared.getCurrentDateTime(.TIME)
    }
}


var propCurrentDate : String {
    get {
        return MyDateTime.shared.getCurrentDateTime(.DATE)
    }
}


var propCurrentDateTime: String {
    get {
        return MyDateTime.shared.getCurrentDateTime(.DATETIME)
    }
}

var propTimeZone: String {
    get {
        return MyDateTime.shared.getTimeZone()
    }
}
