<img src ="https://github.com/user-attachments/assets/0abd18c7-e832-44fc-99e7-9604d8fae656" height="300">

# MOUP
<img src ="https://github.com/user-attachments/assets/62d6691e-0010-45a5-a754-8f201454997f">
<img src ="https://github.com/user-attachments/assets/eb2a4ae7-9ba0-4007-8ea4-265c55ed8858">


## "모이면 업이 된다 MOUP"
> ***MOUP은 알바생과 사장님이 함께 사용하는 근무 관리 플랫폼입니다.***
> 
> 
> *복잡한 근무 시간 계산과 급여 관리를 간편하게 해결하여*<br>
> *알바생에게는 복잡할 수 있는 근무 시간 • 급여 계산을 돕고, 사장님의 인건비 • 근무 일정의 효율적인 관리를 지원합니다 !*


<br><br>
## 5rganization



<img src="https://github.com/user-attachments/assets/182646ff-97cd-4c25-96c8-7edc91c39450" width="160"> | <img src="https://github.com/user-attachments/assets/62b319b2-6718-496a-9c60-1ca3563e4a0b" width="160"> | <img src="https://github.com/user-attachments/assets/701f9995-1a85-444a-97c0-05b5ce8e9a8f" width="160"> | <img src="https://github.com/user-attachments/assets/a448d21a-ce4c-41cf-b63f-5cb8c3fd321d" width="160"> | <img src="https://github.com/user-attachments/assets/882dcce8-a4f9-4a71-b6a7-06ddcfa50d4f" width="160"> | <img src="https://github.com/user-attachments/assets/4378d8fb-c022-4a89-9b06-eb187f743ac7" width="160"> 
:---------:|:----------:|:---------:|:---------:|:---------:|:---------:|
송규섭 | 서동환 | 양원식 | 신재욱 | 김신영 | 조유빈
[GitHub](https://github.com/SongKyuSeob) | [GitHub](https://github.com/SNMac) | [GitHub](https://github.com/Sheep1sik) | [GitHub](https://github.com/tls427wodnr) | [GitHub](https://github.com/ksyq12) |
<br>





## 💻 Development Environment

<img src ="https://img.shields.io/badge/Xcode-16.3-blue?logo=xcode" height="30"> <img src ="https://img.shields.io/badge/iOS-16.0-white.svg" height="30">

<br>

## 주요 기능
- 시연 영상

[![Video Label](http://img.youtube.com/vi/sKyvHlRNo44/0.jpg)](https://youtube.com/shorts/sKyvHlRNo44)
<br>

<details>
<summary> 급여, 인건비 계산 </summary>
	
![알바생 급여 계산1](https://github.com/user-attachments/assets/43d014b0-479f-4230-bfbf-b2d915d3c438)
![알바생 급여 계산2](https://github.com/user-attachments/assets/eb00f77b-78b7-493a-b9ea-e82426e81a08)

> **급여/인건비 계산**
>
> - 근무지 등록시 해당 근무지에 대한 시급/고정급을 입력하면 실제 근무한 시간에 맞춰 자동으로 급여/인건비를 계산합니다.
> - (알바생) 한 근무지에서 이번달 오늘까지 번 돈과 모든 근무지에서 총 급여를 계산하여 제공합니다.
> - (사장님) 나의 매장에 속한 알바생들 각각의 인건비, 총 인건비를 계산하여 제공합니다.
<br>
</details>

<details>
<summary> 개인/공유 캘린더 </summary>
	
![알바생 캘린더](https://github.com/user-attachments/assets/59badc09-b03a-458a-a620-6a6101b85491)

> **개인/공유 캘린더**
>
> - 개인 캘린더는 사용자가 언제 근무가 있는지, 해당 근무의 급여는 얼마인지 보여주는 캘린더 입니다.
> - 공유 캘린더에선 근무지/매장마다 근무하는 모든 인원의 근무 일정을 알 수 있습니다.
> - 필터 기능을 통해 사용자가 원하는 근무지의 일정만 선택하여 보는것이 가능합니다.
<br>
</details>

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
