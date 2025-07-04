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





## 💻 개발 환경

<img src ="https://img.shields.io/badge/Xcode-16.3-blue?logo=xcode" height="30"> <img src ="https://img.shields.io/badge/iOS-16.0-white.svg" height="30">

<br>

## 📋 주요 기능
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


## 🛠️ 기술 스택

범위 | 기술 이름 |
:---------:|:----------:|
의존성 관리 도구 | `SPM`, `CocoaPods`
형상 관리 도구 | `GitHub`, `Git`
아키텍처 | `MVVM`, `Clean Architecture`
디자인 패턴 | `Singleton`, `Delegate`
인터페이스 | `UIKit`
비동기 처리 | `RxSwift`, `RxCocoa`, `RxDataSources`
UI 라이브러리 | `JTAppleCalendar`, `BetterSegmentedControl`
레이아웃 구성 | `SnapKit`, `Then`
내부 저장소 | `UserDefaults`
외부 저장소 | `Cloud Firestore`
외부 인증 | `Firebase Auth`, `Sign in with Apple`. `Goolge Sign in`
코드 컨벤션 | `StyleShare - Swift Style Guide`
커밋 컨벤션 | `Udacity Git Commit Message Style Guide`


<br>


## 🤔 기술적 의사결정
<details>
	<summary> MVVM, Clean Architecture: 각 계층간의 책임을 분리하고, 의존성을 최소화 및 UseCase의 재사용성을 높임 </summary>	
	
	- 문제 상황
	  - 하나의 화면 수정 시 다양한 책임들이 얽혀 코드 변경 범위가 커짐. 비즈니스 로직, 네트워크 처리, 상태 관리, UI 처리가 모두 강하게 결합되는 문제가 발생
	- MVVM과 Clean Architecture를 도입하여 View는 UI 처리만 담당, 상태 관리는 ViewModel에서, 비즈니스 로직을 UseCase, Repository, Data Layer로 완전히 분리
        - 장점
          - 레이어 간 인터페이스를 명확히 하여 의존성 주입이 쉬운 구조로 개발
          - 역할을 분리하여 책임이 명확해지고 깔끔한 코드 작성 가능
          - 새로운 기능을 도입하거나 교체해도 도메인 로직에 영향 없음
          - ViewModel은 UseCase에만 의존하기 때문에 앱의 핵심 로직 추상화 가능
          - 상위 계층(Presentation)이 하위 계층(Data)의 구현체가 아니라 추상 타입에 의존하여 구체적인 구현을 몰라도 되는 구조
          - 인터페이스(Protocol)를 가운데에 두고, 상위 계층과 하위 계층이 인터페이스를 바라보기 때문에 의존성 역전이 발생함

 </details>

<details>
	<summary> SwiftUI vs JTAppleCalendar </summary>
	
	- 캘린더의 구현 방법을 정할 때 SwiftUI와 외부 라이브러리 사이에서 고민
	- UIKit+RxSwift의 일관성과 커스텀 자유도를 높이기 위해 JTAppleCalendar 채택

</details>

<details>
	<summary> SPM vs CocoaPods </summary>
	
	- CocoaPods만 지원하는 라이브러리인 JTAppleCalendar를 도입할 때 SPM과 CocoaPods를 혼용할지, CocoaPods로 모든 라이브러리를 통합할지 고민
	- SPM이 갖는 이점인 Xcode와 통합된 환경, 빠른 빌드 시간을 가져가기 위해 JTAppleCalendar만 별도로 CocoaPods로 관리
	
</details>


<details>
	<summary> RxSwift, RxCocoa, RxDataSources: 비동기 데이터 흐름을 효율적으로 처리하고, 사용자 인터페이스가 데이터 상태에 따라 자연스럽게 반응하도록 구현하기 위해 사용 </summary>
	
	- Input 구조체는 다양한 사용자 이벤트를 Observable 형태로 받아 이벤트 흐름을 선언형으로 정의하고 각각의 반응을 명확하게 구분
	- ViewModel 내부 상태는 Relay로 관리하여 UI에 필요한 데이터를 보존하고, 외부에서는 `.asObservable()`로 안전하게 구독하여 View와 단방향 바인딩 가능
	- `transform()` 메서드 내부에서 `.flatMap` 등 다양한 연산자를 사용해 이벤트 흐름을 구성하고 코드의 가독성과 유지보수성 향상 가능. 비동기 데이터 흐름과 에러처리, 사이드 이펙트 처리 가능
	- Output으로 정의한 데이터를 View에서는 UI만 반응하게 하여 상태 변화와 UI 이벤트 처리 분리 가능
	
</details>

<details>
	<summary> Cloud Firestore: 백엔드 구현 없이 사용자가 입력한 근무지/매장 정보, 근무 정보를 DB에 저장하기 위해 사용 </summary>
	
	- 의사결정 당시 팀 내 상황
	  - 짧은 일정으로 빠른 MVP 개발 및 배포를 진행하고 유저 테스트를 거쳐 앱 업데이트를 목표로 삼음
	- 도입시 장점
	  - Firestore는 문서(document)와 컬렉션(collection) 구조로 되어 있어 유연한 데이터 모델링 가능
	  - 로그인/인증과 연동이 필요했고 팀원 모두가 동시에 접근하고 협업 가능한 구조 필요
	  - 따로 백엔드를 관리하거나 서버 인프라를 관리하지 않아도 되고, 콘솔에서 바로 데이터 확인/수정 가능
 
 </details>

 - Firebase Auth, Google Auth SDK, Apple Auth SDK: 구글, 애플 로그인 기능을 지원하고, 이를 통한 인증을 통합하여 처리
 - BetterSegmentedControl: 커스터마이징이 자유로운 iOS 스타일 세그먼트 컨트롤 컴포넌트
 - UserDefaults: 앱 설치 이후 최초 실행인지 확인하고, 최초 실행인 경우 사용 안내 이미지를 표시하기 위해 사용
 - SnapKit: Auto Layout을 보다 직관적이고 간결하게 작성하기 위해 사용
 - Then: 초기화 직후 속성 설정을 간결하게 작성할 수 있는 라이브러리

<br>
 

## 📂 폴더 구조

<details>
<summary> 프로젝트 폴더 구조 </summary>
<div markdown="1">

```bash
.
├── App
├── Common
│   ├── Managers
│   └── Utils
├── Data
│   ├── Repositories
│   └── Services
├── Domain
│   ├── Entities
│   ├── Interfaces
│   └── UseCases
├── Presentation
│   ├── Calendar
│   ├── Components
│   ├── Home
│   ├── Login
│   ├── MyPage
│   ├── Notification
│   ├── Onboarding
│   ├── Registration
│   ├── Routine
│   ├── Signup
│   └── TabBar
└── Resources
    ├── Assets.xcassets
    ├── Base.lproj
    ├── Firebase
    ├── Fonts
    ├── JSON
    └── ko.lproj

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
