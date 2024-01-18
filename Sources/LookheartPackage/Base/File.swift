import Foundation
import FSCalendar
import Then

class CustomCalendar : UIView, FSCalendarDelegate, FSCalendarDataSource {
 
    private var calendar: FSCalendar

    override init(frame: CGRect) {
        self.calendar = FSCalendar(frame: frame)
        super.init(frame: frame)
        setupCalendar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.calendar = FSCalendar(frame: CGRect.zero)
        super.init(coder: aDecoder)
        setupCalendar()
    }
    
    private func setupCalendar() {
        calendar.backgroundColor = UIColor(red: 241/255, green: 249/255, blue: 255/255, alpha: 1)
        calendar.appearance.headerTitleColor = UIColor.MY_BLUE
        calendar.appearance.selectionColor = UIColor.MY_BLUE
        calendar.appearance.weekdayTextColor = UIColor.MY_BLUE
        calendar.appearance.todayColor = UIColor.MY_RED
        calendar.scrollEnabled = true
        calendar.scrollDirection = .vertical
        calendar.layer.cornerRadius = 10
        calendar.layer.borderColor = UIColor.MY_SKY.cgColor
        calendar.layer.borderWidth = 2
        calendar.clipsToBounds = true
        calendar.delegate = self
        calendar.dataSource = self
        addSubview(calendar)
    }
    
    internal func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("선택된 날짜: \(date)")
    }
    
    internal func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("해제된 날짜: \(date)")
    }
    
}
