// Kevin Li - 11:47 AM - 6/13/20

import ElegantCalendar
import SwiftUI

struct ExampleCalendarView: View {

    @ObservedObject private var calendarManager: ElegantCalendarManager

    let visitsByDay: [Date: [Visit]] = [:]
    var onChangeMonth: ((Date) -> Void)?
    @State private var calendarTheme: CalendarTheme = .craftBrown
    @State private var isSwipeUporDown: Bool = false
    @State var sizeShiftheight : CGFloat = 450
    private var shiftsDate: [Int]
    init(startDate: Date, endDate: Date, initialMonth: Date?, shiftsDate: [Int] = [], onChangeMonth: ((Date) -> Void)? = nil) {
        
        self.shiftsDate = shiftsDate
        self.onChangeMonth = onChangeMonth
        let configuration = CalendarConfiguration(
            calendar: currentCalendar,
            startDate: startDate,
            endDate: endDate)

        calendarManager = ElegantCalendarManager(
            configuration: configuration,
            initialMonth: initialMonth)
        
//        visitsByDay = Dictionary(
//            grouping: Visit.mocks(
//            start: Date(),
//            end: .daysFromToday(30*24)),
//            by: { currentCalendar.startOfDay(for: $0.arrivalDate) })

        calendarManager.datasource = self
        calendarManager.delegate = self
    }

    var body: some View {
        ZStack {
            ElegantCalendarView(calendarManager: calendarManager)
//                .theme(calendarTheme)
//                .animation(.easeInOut(duration: 0.5))
            
            VStack {
                VStack {
                    Spacer()
                    HStack {
                        Text("My Schedule")
                            .font(Font.robotoBold34)
                            .foregroundColor(.yellow)
                        Spacer()
                        Image(systemName: "plus.circle")
                    }
                }
                .padding([.leading, .trailing], 24)
                .padding(.bottom, 4)
                .frame(height: (UIScreen.main.bounds.height * 88) / 812)
                .background(Color.lividBrown)
                Spacer()
            }
            
            ShiftView(isSwipeUporDown: $isSwipeUporDown, shiftsDate: shiftsDate)
                .cornerRadius(20)
                .offset(y: sizeShiftheight)
                .gesture(DragGesture()
                            .onChanged({ (value) in
                                print("value: \(value.translation.height)")
                                isSwipeUporDown = true
                            })
                            .onEnded({ (value) in
                                print("value onEnded: \(value.translation.height)")
                                if value.translation.height > 20, sizeShiftheight < 450 {
                                    self.sizeShiftheight = 450
                                }
                                if value.translation.height < -20, sizeShiftheight == 450 {
                                    self.sizeShiftheight = 70
                                }
                                isSwipeUporDown = false
                            })).animation(.easeInOut(duration: 0.5))
                .opacity(calendarManager.isShowingYearView ? 1 : 0)
                .animation(.spring())
//                .animation(.easeInOut(duration: 0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }

    private var changeThemeButton: some View {
        ChangeThemeButton(calendarTheme: $calendarTheme)
    }
    
}

extension ExampleCalendarView: ElegantCalendarDataSource {

    func calendar(isShiftDate date: Date) -> Bool {
        // shift date
        let day = currentCalendar.dateComponents([.day], from: date).day!
        return (shiftsDate.firstIndex(of: day) != nil)
    }
    
    func calendar(viewForSelectedDate date: Date, dimensions size: CGSize) -> AnyView {
        let startOfDay = currentCalendar.startOfDay(for: date)
        return VisitsListView(visits: visitsByDay[startOfDay] ?? [], height: size.height).erased
    }
    
}

extension ExampleCalendarView: ElegantCalendarDelegate {

    func calendar(didSelectDay date: Date) {
        print("Selected date: \(date)")
    }

    func calendar(willDisplayMonth date: Date) {
        print("Month displayed: \(date)")
        onChangeMonth?(date)
    }

    func calendar(didSelectMonth date: Date) {
        print("Selected month: \(date)")
    }

    func calendar(willDisplayYear date: Date) {
        print("Year displayed: \(date)")
    }

}

struct ShiftView : View {
    
    @Binding var isSwipeUporDown: Bool
    let shiftsDate: [Int]
    
    var body : some View{
        GeometryReader { geo in
        VStack{
            Text("Swipe Up or Down")
                .fontWeight(.heavy)
                .padding([.top,.bottom],15)
                .foregroundColor(isSwipeUporDown ? .black : .gray)
            VStack {
                ForEach(shiftsDate, id: \.self) { item in
                    HStack {
                        Text("\(item)")
                        Spacer()
                    }
                }
            }
            Spacer()
        }
        .background(Color.yellow)
        .frame(width: geo.size.width, height: geo.size.height - 130)
        }
    }
}
