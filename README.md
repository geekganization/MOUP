![image](https://github.com/user-attachments/assets/b913fe2a-84a4-4a95-b94c-d4fb9e810429)



# MOUP
모이면 업이 된다 — MOUP

알바생의 근무 시간, 날짜, 월급을 자동으로 계산하고, 루틴(체크리스트) 기능으로 업무를 더 쉽게 관리할 수 있는 앱입니다.

<br><br>
## MOUP



<img src="https://github.com/user-attachments/assets/182646ff-97cd-4c25-96c8-7edc91c39450" width="160"> | <img src="https://github.com/user-attachments/assets/62b319b2-6718-496a-9c60-1ca3563e4a0b" width="160"> | <img src="https://github.com/user-attachments/assets/701f9995-1a85-444a-97c0-05b5ce8e9a8f" width="160"> | <img src="https://github.com/user-attachments/assets/a448d21a-ce4c-41cf-b63f-5cb8c3fd321d" width="160"> | <img src="https://github.com/user-attachments/assets/882dcce8-a4f9-4a71-b6a7-06ddcfa50d4f" width="160"> | <img src="https://github.com/user-attachments/assets/4378d8fb-c022-4a89-9b06-eb187f743ac7" width="160"> 
:---------:|:----------:|:---------:|:---------:|:---------:|:---------:|
송규섭 | 서동환 | 양원식 | 신재욱 | 김신영 | 조유빈
[GitHub](https://github.com/SongKyuSeob) | [GitHub](https://github.com/SNMac) | [GitHub](https://github.com/Sheep1sik) | [GitHub](https://github.com/tls427wodnr) | [GitHub](https://github.com/ksyq12) |
<br>





## 💻 Development Environment

<img src ="https://img.shields.io/badge/Xcode-16.3-blue?logo=xcode" height="30"> <img src ="https://img.shields.io/badge/iOS-16.0-white.svg" height="30">

<br>

## 📖 Using Library

라이브러리 | 사용 목적 | Management Tool
:---------:|:----------:|:---------:
SnapKit | UI Layout | SPM
Then | UI 선언 | SPM
RxSwift | 데이터 바인딩을 통한 비동기 데이터 흐름 처리 | SPM
RxCocoa | UI 컴포넌트(예: 버튼 `rx.tap`)의 반응형 이벤트 처리 | SPM
RxDataSources | `UITableView`, `UICollectionView`의 데이터 처리 | SPM
Firebase | Authentication과 NoSQL | SPM
BigInt | 초대 코드 생성 시 중복 검사 및 변환 | SPM
BetterSegmentedControl | 홈 상단 스위치 커스텀 UI | SPM
JTAppleCalendar | 달력 커스텀 | Cocoapods


<br>

## 📂 Folder Architecture

<details>
<summary> 프로젝트 폴더 구조 </summary>
<div markdown="1">

프로젝트 폴더 구조만 정리해드리겠습니다:

```bash
Routory
└── Routory
    ├── Routory
    │   ├── App
    │   ├── Common
    │   │   ├── Managers
    │   │   └── Utils
    │   │       └── Extensions
    │   ├── Data
    │   │   ├── Repositories
    │   │   └── Services
    │   │       └── DelegateProxies
    │   ├── Domain
    │   │   ├── Entities
    │   │   │   └── Dummy
    │   │   ├── Interfaces
    │   │   │   ├── Repositories
    │   │   │   └── UseCases
    │   │   └── UseCases
    │   ├── Presentation
    │   │   ├── Calendar
    │   │   │   ├── Utils
    │   │   │   ├── View
    │   │   │   │   ├── Cell
    │   │   │   │   └── Components
    │   │   │   ├── ViewController
    │   │   │   │   └── Delegates
    │   │   │   └── ViewModel
    │   │   ├── Components
    │   │   ├── Home
    │   │   │   ├── View
    │   │   │   │   ├── Cell
    │   │   │   │   └── Section
    │   │   │   ├── ViewController
    │   │   │   └── ViewModel
    │   │   ├── Login
    │   │   │   ├── View
    │   │   │   └── ViewModel
    │   │   ├── MyPage
    │   │   │   ├── View
    │   │   │   ├── ViewController
    │   │   │   └── ViewModel
    │   │   ├── Notification
    │   │   │   ├── View
    │   │   │   ├── ViewController
    │   │   │   └── ViewModel
    │   │   ├── Onboarding
    │   │   │   ├── View
    │   │   │   ├── ViewController
    │   │   │   └── ViewModel
    │   │   ├── Registration
    │   │   │   ├── Components
    │   │   │   ├── Handler
    │   │   │   ├── Helpers
    │   │   │   ├── ShiftRegistration
    │   │   │   │   ├── Enum
    │   │   │   │   ├── Handler
    │   │   │   │   ├── Submodules
    │   │   │   │   │   ├── ColorSelection
    │   │   │   │   │   └── EmployeeSelection
    │   │   │   │   ├── View
    │   │   │   │   ├── ViewController
    │   │   │   │   └── ViewModel
    │   │   │   └── WorkplaceRegistration
    │   │   │       ├── Handler
    │   │   │       ├── View
    │   │   │       ├── ViewController
    │   │   │       └── ViewModel
    │   │   ├── Routine
    │   │   │   ├── View
    │   │   │   │   └── Cell
    │   │   │   ├── ViewController
    │   │   │   └── ViewModel
    │   │   ├── Signup
    │   │   │   ├── View
    │   │   │   └── ViewModel
    │   │   └── Tabbar
    │   │       └── ViewController
    │   └── Resources
    │       ├── Assets.xcassets
    │       │   ├── AccentColor.colorset
    │       │   ├── AppIcon.appiconset
    │       │   ├── Colors
    │       │   │   ├── Background
    │       │   │   ├── Common
    │       │   │   ├── Gray
    │       │   │   ├── Modal
    │       │   │   ├── Primary
    │       │   │   └── TextColor
    │       │   ├── Icons
    │       │   │   ├── Bell
    │       │   │   ├── Calendar
    │       │   │   ├── Category
    │       │   │   ├── Check
    │       │   │   ├── Checkbox
    │       │   │   ├── Chevron
    │       │   │   ├── Ellipsis
    │       │   │   ├── Home
    │       │   │   ├── Logo
    │       │   │   ├── MyPage
    │       │   │   ├── Radio
    │       │   │   └── Refresh
    │       │   └── Images
    │       │       ├── AppleLogin
    │       │       ├── GoogleLogin
    │       │       └── Illustration
    │       ├── Base.lproj
    │       ├── Fonts
    │       ├── JSON
    │       └── ko.lproj
    ├── Routory.xcodeproj
    │   └── project.xcworkspace
    └── Routory.xcworkspace
        └── xcshareddata
            └── swiftpm
```
  
</details>

<br>
	
## 🌷 역할 분담
<details>
<summary> 송규섭 </summary>
<div markdown="1">
	
 - 역할 별 홈 구현
 - 루틴 관리 구현


</div>
</details>
	
<details>
<summary> 서동환 </summary>
<div markdown="1"> 

 - JTAppleCalendar 라이브러리를 통한 캘린더 구현
 - Apple 로그인 구현


</div>
</details>
  
<details>
<summary> 양원식 </summary>
<div markdown="1">

 - Google 로그인 구현
 - Firebase 관련 핵심 서비스 연동
 - 도메인 레이어까지 구현


</div>
</details>

<details>
<summary> 신재욱 </summary>
<div markdown="1">
	
 - 근무지 등록/수정 구현
 - 근무 등록/수정 구현
 - 루틴 등록/수정 구현

 

</div>
</details>

<details>
<summary> 김신영 </summary>
<div markdown="1">
	
 - 초대 코드로 근무지 등록
 - 마이페이지 구현
   

</div>
</details>

<details>
<summary> 조유빈 </summary>
<div markdown="1">
	
 - 와이어프레임
 - UI 구성
 - 디자인 시스템 제작
 - 전반적인 화면 디자인
   

</div>
</details>
