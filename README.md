# 🪪 신용카드 추천 리스트 앱 (Feat. 은행앱)

백엔드에서 잠시 놀다 온 필자

다시 돌아왔다.

Readme만 딱 봐도 많은 것이 발전하고 달라진 것이 보인다.

백엔드(Spring)을 공부하고 배우며 많은 것을 배우고, iOS에 대한 짙은 향수를 느꼈다.

그래서 돌아왔다!!!

어쨌든 오늘 만들어 볼 앱은 바로 대다수의 은행앱에서 자주 쓰이는 [신용카드 추천 리스트 앱]이다

마지막 개인 프로젝트였던 로그인 샘플 앱에서 쓰였던 백엔드 대체 플랫폼인 Firebase를 여전히 사용할 것이다.

Firebase 컴포넌트인 Database를 이용해서 이 Database에 신용카드 추천 정보들을 저장하고 이를 Client에서 불러들여 카드 혜택 정보를 제공하는 앱을 만들어 볼 것이다!

## Firebase Realtime Database 알아보기

데이터베이스는 데이터의 집합체, 일반적으로 관계형 데이터 베이스 형태 (Spring 할 때 많이 배웠다)

Firebase에서 제공하는 실시간 데이터베이스는 비관계형 데이터베이스이다.

비관계형 데이터베이스는 많은 정보를 수집하는 모바일, 웹 등에 적합하다.

우리가 일반적으로 아는 관계형 데이터베이스는 각 entity가 별도로 존재하며 관계를 이루어 전체적인 정보를 전달한다면, 비관계형 데이터베이스는 JSON 기반의 데이터를 가져오고 내보내고 관리하는데 최적화 되어있어, 여로 테이블로 산재되어있던 열들을 모두 갖는 하나의 단일 문서 내의 속성으로 저장될 것이다.

또 실시간 데이터베이스라는 이름 그대로, 실시간으로 작동해서 

우리가 일반적으로 아는 데이터베이스는 client로부터 http api 를 이용해 request를 받아와서 값을 받아오는데,

실시간 데이터베이스는 옵저버와 스냅샷 같은 객체를 제공하는 SDK를 통해 client와 직접 실시간으로 동기화하게 된다. 따라서 실시간 데이터베이스와 연결된 모든 기기는 거의 동시에 서버에 모든 변경사항을 실시간으로 반영할 수 있다. 

앱이 오프라인 상태일 때도, 로컬에 저장해뒀다가 네트워크 연결 시 동기화하는 방식으로 운영되고 

가장 강력한 기능인 

**별도의 서버 없이 바로 데이터베이스와 client를 연결!!** 해준다는 것이다.

## Firebase Firestore Database 알아보기

실시간 데이터베이스 이후에 나온, 비교적 최신 플랫폼이다.

실시간 데이터베이스와 같이 비관계형 데이터베이스로 거의 비슷한 기능 제공한다.

- 실시간 : Http 요청이 아닌 동기화 방식
- 오프라인 : 로컬에 저장 후 네트워크 연결시 동기화
- 서버 없이 : 데이터베이스와 클라이언트 직접 엑세스

그럼 대체 어떤 점이 다른 걸까??

→ Firebase에서는 둘이 제공하는 데이터 모델이 차이가 있고, 따라서 데이터 베이스를 사용하고자 하는 앱이 어떤 특성을 가지냐에 따라 권장하는 데이터베이스가 다르다고 설명한다.

무엇보다 Firestore가 보다 복합적인 쿼리를 제공한다고 한다!!!

## Realtime Database

- 데이터 모두를 하나의 큰 JSON 트리로 저장
- 하나의 문서에 정렬 || 필터링 가능 (동시에 불가)
- 깊고 좁은 쿼리(즉 결과값이 갖는 하위값 모두 반환 하위값까지 접근 가능)
- 데이터 세트가 커질수록 쿼리 성능 떨어짐(깊으니까)
    - 기본적인 데이터 동기화
    - 적은양의 데이터가 자주 변경
    - 간단한 JSON 트리
    - 많은 데이터베이스

## Cloud Firestore

- JSON과 유사하지만 JSON이 아닌 문서와 컬렉션의 조합으로 제공. 즉 하나의 컬렉션이 여러개의 문서를 갖고 각각의 문서는 하위에 컬렉션을 가질 수 있는 구조
- 하나의 문서에 정렬 && 필터링 가능
- 얕고 넓은 쿼리(특정 컬렉션의 문서만 반환 해당 문서가 하위에 컬렉션을 갖고 있어도 반환 안함)
- 데이터 세트가 커질수록 쿼리 성능과는 직접적인 관계 없음
    - 고오급 쿼리, 정렬, 트랜젝션
    - 대용량 데이터가 자주 읽힘
    - 구조화된 컬렉션
    - 단일 데이터베이스

우리는 이번에 둘 다 구현할것임!!

만든 과정은 다음과 같다.

CardListViewController 제작 → CreditCard 객체 제작(JSON 받을 꺼) → CustomCell 제작(also created xib로 UI 구성하는 것이 더 쉬움) → CardListViewController와 CustomCell 연결해서 라벨 만들고 delegate 구성(이때 Kingfisher로 이미지 Url 받아서 이미지뷰에 표현)

```swift
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardListCell", for: indexPath) as? CardListCell else {return UITableViewCell()}
        //cell.rankLabel.text = "\(creditCardList[indexPath.row].rank)위"
        //cell.promotionLabel.text = "\(creditCardList[indexPath.row].promotionDetail.amount)만원 증정"
        //cell.cardNameLabel.text = "\(creditCardList[indexPath.row].name)"
        
        let imageURL = URL(string: creditCardList[indexPath.row].cardImageURL)
        cell.cardImageView.kf.setImage(with: imageURL)
        
        //return cell
    }
```

이런식으로 Kingfisher 사용

→셀을 탭 했을 때 들어갈 상세 화면 CardDetailViewController 제작(이때 로티를 통해 움직이는 이미지 넣어줬다: 얘도 코코아팟 이용해서 설치) → 마지막으로 CardListViewController에서 didSelectRowAt 만들어줘서 

```swift
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //상세화면 전달하기
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController else { return }
        
        detailViewController.promotionDetail = creditCardList[indexPath.row].promotionDetail
        self.show(detailViewController, sender: nil)
    }
```

선택한 cell의 promotionDetail 넘겨주면 끝

이럼 기본 UI 구성이 끝난다!!

<img width="1790" alt="기본UI" src="https://github.com/jinyongyun/Credit_Card_List_APP/assets/102133961/af9e5e4c-15ab-4e92-bfab-2848d38a655b">



https://github.com/jinyongyun/Credit_Card_List_APP/assets/102133961/009dcf13-0c62-40d0-af28-42f177fb4db3



이제 Firebase Realtime db를 연결해보자

늘 하던대로 프로젝트 만들어주고, bundle ID 복사해주고, GoogleService-info 파일 추가해주고 Realtime Database로 이동!!
<img width="1372" alt="스크린샷 2023-12-23 오후 11 27 14" src="https://github.com/jinyongyun/Credit_Card_List_APP/assets/102133961/b7777bbf-6939-461c-988f-4e6a895f15f4">
podfile에서 Firebase 설치과정에서 문제가 발생했다

**DT_TOOLCHAIN_DIR cannot be used to evaluate LIBRARY_SEARCH_PATHS, use TOOLCHAIN_DIR instead**

요딴 문구가 뜨면서 빌드가 안되는데, xcode 버전 업데이트에 cocoapod 버전이 못따라가서 발생한 문제라고 한다. cocoapods 업데이트를 해줘야 한다.

`$ sudo gem install cocoapods`

를 해주려고 했는데 에러 발생 

ignoring ffi-1.15.5 because its extensions are not built. try: gem pristine ffi --version 1.15.5

뭐가 문제인가 생각해보다, 혹시 코코아팟을 업데이트 해주는 루비 자체에서 문제가 생긴건가 싶어서 루비를 업데이트 해줬다. 루비 업데이트 후 코코아팟 업데이트까지 해주니…

- 해결과정
    
    > 1. brew update
    > 
    > 
    > 커멘드를 이용해 brew 업데이트
    > 
    
    > 2. brew install rbenv ruby-build
    > 
    > 
    > 'rbenv' 설치
    > 
    > 'rbenv versions' 으로 버전확인 시 아래와 같이 나오면 설치 완료
    > 
    > ```
    > * system
    > ```
    > 
    > [* system] -> 현재 사용중인 버전은 맥북의 기본 system 버전이라는 뜻
    > 
    
    > 3. rbenv install -l
    > 
    
    설치 가능한 버전 리스트 확인
    
    > 4. rbenv install 2.7.4
    > 
    > 
    > 원하는 버전 설치
    > 
    
    > 5. rbenv versions
    > 
    > 
    > 버전 다시 확인, 아래와 같이 나오면 설치 완료
    > 
    > ```
    > * system
    >   2.7.4
    > ```
    > 
    
    > 6. rbenv global 2.7.2
    > 
    > 
    > system으로 되어있는 default ruby를 새로 설치한 버전으로 변경
    > 
    > 'rbenv versions' 으로 버전확인 시 아래와 같이 나오면 변경 완료
    > 
    > ```
    >   system
    > * 2.7.4 (set by /Users/{사용자이름}/.rbenv/version)
    > ```
    > 
    
    > 6. Path를 지정
    > 
    > 
    > Path를 지정하기 위해 아래 명령어 입력
    > 
    > ```
    > echo '# rbenv' >> ~/.zshrc
    > echo 'export PATH=~/.rbenv/bin:$PATH' >> ~/.zshrc
    > echo 'eval "$(rbenv init -)"' >> ~/.zshrc
    > 
    > source ~/.zshrc
    > ```
    > 

그랬더니 빌드 성공!!
```swift
import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
```

AppDelegate에 다음과 같이 초기화 하면 Firebase 연결 끝!

우리는 디비에서 CardListViewController의 **var** creditCardList: [CreditCard] = [] 형태로 데이터를 가져올거니까, CardListViewController에 FirebaseDatabase를 import해준다.

```swift
var ref: DatabaseReference!  //Firebase Realtime Database를 가져올 수 있는 reference 값
```

그 다음 다음과 같이 DatabaseReference를 선언해준다. 

```swift
override func viewDidLoad() {
        super.viewDidLoad()
        
        //UITableView Cell register
        let nibName = UINib(nibName: "CardListCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CardListCell")
        
        ref = Database.database().reference()
        
    }
```

viewDidLoad에 다음과 같이 Database.database().reference() 선언을 해주면 Firebase가 우리가 만든 db를 잡아내고 데이터 흐름을 주고받을 것이다.

이제 db에 저장해 둔 데이터를 가져와 보자

```swift
override func viewDidLoad() {
        super.viewDidLoad()
        
        //UITableView Cell register
        let nibName = UINib(nibName: "CardListCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CardListCell")
        
        ref = Database.database().reference()
        
        ref.observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {return}
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let cardData = try JSONDecoder().decode([String: CreditCard].self, from: jsonData)
                let cardList = Array(cardData.values)
                self.creditCardList = cardList.sorted { $0.rank < $1.rank }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch let error {
                print("ERROR JSON parsing \(error.localizedDescription)")
            }
        }
    }
```

실시간 데이터 베이스는 snapshot이란 객체를 통해서 데이터를 불러온다.

reference에서 값을 지켜보고 있다가 값을 snapshot이라는 객체로 전달하게 된다.

우리는 이 객체를 클로저 내에서 잘 가공한 뒤 이용하면 된다.

전달되는 snapshot에서 value는 우리가 이해하고 있는 데이터베이스의 형태를 지정해주는 것이다.

[String: [String: Any]] 이렇게 타입을 정확하게 지정하지 않으면 디비는 스냅샷에서 전달받은 값을 이해하지 못해 항상 nil을 방출하게 된다.

제대로 value를 전달 받았다면 우리는 codable의 decode를 통해 기존에 만들어두었던 creditCard 객체의 배열로 만들어줄 수 있다. 

이후 전달을 잘 받았다면 self.tableView.reloadData() 이렇게 테이블 뷰 리로드를 해줘야 받은 데이터가 잘 표현될텐데 UI를 표현하는 것이니 메인스레드에서 작동을 해야한다. 따라서 DispatchQueue 설정을 따로 해준것이다.


https://github.com/jinyongyun/Credit_Card_List_APP/assets/102133961/6e54902e-3379-4a3e-886f-b380058000c7


이제 이렇게 잘 읽어온 데이터베이스를 단순히 읽어 오는 것 뿐만이 아니라 앱의 특정 액션을 통해 앱을 통해 데이터베이스에 쓸 수 있도록 할 것이다.

처음 Firebase에서 JSON 파일 가져오기 옵션으로 디비에 데이터를 작성했는데, 이번에는 웹 콘솔이 아니라 앱의 액션을 통해서 전달해보겠다.

사용자가 셀을 선택할때마다 CreditCard 객체에 있는 isSelected 값에 true라는 값을 부여하고 이것을 디비에 작성해보겠다.

```swift
import Foundation

struct CreditCard: Codable {
    let id: Int
    let rank: Int
    let name: String
    let cardImageURL: String
    let promotionDetail: PromotionDetail
    let isSelected: Bool?
    
}

struct PromotionDetail: Codable {
    let companyName: String
    let period: String
    let amount: Int
    let condition: String
    let benefitCondition: String
    let benefitDetail:String
    let benefitDate: String
}
```

CardListViewController에서 didSelectRowAt에다 코드를 추가하면 될 것이라 막연하게 생각된다.

```swift
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //상세화면 전달하기
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController else { return }
        
        detailViewController.promotionDetail = creditCardList[indexPath.row].promotionDetail
        self.show(detailViewController, sender: nil)
        
        **let cardID = creditCardList[indexPath.row].id
        ref.child("Item\(cardID)/isSelected").setValue(true)**
        
    }
```

이렇게 선택한 셀의 CreditCard 객체의 id를 통해 
ref.child로 path를 전달하여 item0/isSelected 경로가 포함하는 곳에 setValue를 true로 설정하면 된다.

실제로 시뮬을 돌려보면 셀을 선택하자마자 디비상에서 isSelected가 새로 생겨나고 해당 값이 true로 바뀌는 것을 알 수 있다.



https://github.com/jinyongyun/Credit_Card_List_APP/assets/102133961/30b2c346-79a8-4540-9fb6-a341acc07510



여기서 문제는 **"Item\(cardID)/isSelected" 이 부분에서 Item\(cardID) 이 값을 key로 isSelected를 지정해준 것이다.**

해당 값은 어떻게 구조화되느냐에 따라 임의의 String이 될 수도 있어 보다 확실히 하려면 객체의 특정 컴포넌트 값을 검색해서 객체의 스냅샷을 가져와야 한다.

```swift
//option 2 : 컴포넌트 물어봐
        ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
            guard let self = self,
                  let value = snapshot.value as? [String: [String: Any]],
                  let key = value.keys.first else {return}
            
            ref.child("\(key)/isSelected").setValue(true)
        }
```

위에서 봤던 snapshot 데이터 읽기와 비슷하다.  데이터 삭제는 nil을 쓰면 된다. (또는 보다 명시적으로 removeValue를 사용해서 - 저기 setValue 대신 removeValue 사용하면 됨 - 삭제하자)

특정 신용카드를 앱 상에서 지우려는 액션을 하면 실제로 데이터베이스에서도 삭제되도록 해보겠다.

```swift
override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Option1
            let cardID = creditCardList[indexPath.row].id
            ref.child("Item\(cardID)").removeValue()
            
            //Option2 : 경로 몰라
//            ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
//                guard let self = self,
//                      let value = snapshot.value as? [String: [String: Any]],
//                      let key = value.keys.first else { return }
//                
//                self.ref.child(key).removeValue()
//
//            }
        }
    }
```

이렇게 테이블뷰에서 셀 수정을 허용하도록 하고(canEditRowAt)
editingStyle 메서드를 선언한 다음 선택한 인덱스에 해당하는 셀의 아이디를 얻어와서 해당 경로로 삭제 명령을 보내거나 아니면 위에서 했던 것처럼 직접 아이디를 검색해서 명령하는 방식이 있다.


https://github.com/jinyongyun/Credit_Card_List_APP/assets/102133961/518eb512-01eb-48fd-a84f-b57acf13d8c8


## 이제 여기서부턴 Firebase Firestore Database 연결!!

pod 'Firebase/Firestore'
pod 'FirebaseFirestoreSwift'

pod 파일에 다음 두 pod을 추가해주고 pod install

Firebase의 Firestore 데이터베이스를 빌드 창에서 선택하여 (테스트 모드로) 만들어준다.

만들어진 Firestore를 보면 컬렉션 > 문서 > 컬렉션 구조로 데이터를 만들 수 있다는 것을 알 수 있다.

안타깝게도 Firestore는 JSON 가져오기를 지원하지는 않는다.

다만 batch로 코드를 통해 읽기 작업을 할 수 있다.

미리 만들어둔 CreditCardDummy 파일을 추가해주고

AppDelegate에 Realtime 때 했던 것과 마찬가지로 초기화를 해줘야 한다.

**import** FirebaseFirestoreSwift 추가해주고 let db = Firestore.firestore() 디비선언

디비에 collection을 만들어줄건데, 이름은 creditCardList 우리는 CreditCardDummy에서 가져오니까 getDocuments 

Firestore도 snapshot을 이용한다!! 

snapshot이 비어있을 때만 실행하고

batch를 하나 만들어주고, 이 batch안에 하나씩 객체를 넣을 수 있도록 파일 경로 즉 reference를 만들어줄 것이다. db에 컬렉션이 있는데, 이 컬렉션의 경로는 “creditCardList”이다. 그리고 document를 추가해줄 건데 이 document의 경로는 card0…이렇게 반복해서 10개의 ref를 만들어주고

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        
        db.collection("creditCardList").getDocuments { snapshot, _ in
            guard snapshot?.isEmpty == true else { return }
            let batch = db.batch()
            
            let card0Ref = db.collection("creditCardList").document("card0")
            let card1Ref = db.collection("creditCardList").document("card1")
            let card2Ref = db.collection("creditCardList").document("card2")
            let card3Ref = db.collection("creditCardList").document("card3")
            let card4Ref = db.collection("creditCardList").document("card4")
            let card5Ref = db.collection("creditCardList").document("card5")
            let card6Ref = db.collection("creditCardList").document("card6")
            let card7Ref = db.collection("creditCardList").document("card7")
            let card8Ref = db.collection("creditCardList").document("card8")
            let card9Ref = db.collection("creditCardList").document("card9")
         
            do {
                try batch.setData(from: CreditCardDummy.card0, forDocument: card0Ref)
                try batch.setData(from: CreditCardDummy.card1, forDocument: card1Ref)
                try batch.setData(from: CreditCardDummy.card2, forDocument: card2Ref)
                try batch.setData(from: CreditCardDummy.card3, forDocument: card3Ref)
                try batch.setData(from: CreditCardDummy.card4, forDocument: card4Ref)
                try batch.setData(from: CreditCardDummy.card5, forDocument: card5Ref)
                try batch.setData(from: CreditCardDummy.card6, forDocument: card6Ref)
                try batch.setData(from: CreditCardDummy.card7, forDocument: card7Ref)
                try batch.setData(from: CreditCardDummy.card8, forDocument: card8Ref)
                try batch.setData(from: CreditCardDummy.card9, forDocument: card9Ref)
            } catch let error {
                print("ERROR writing card to Firestore \(error.localizedDescription)")
            }
            
            
            batch.commit()
        }
        
        return true
    }
```

이제 범위에 있는 아이들을 batch에 넣어줘야 한다. setData 함수가 throw 함수라 do try catch 구문에 넣어준다.

이렇게 하면 데이터 설정까지 완료, 중요한 것은 **batch에서 마지막에 꼭 commit을 해줘야!!** 

실행시켜보면 firebase Firestore에 데이터가 제대로 들어가 있는 것을 확인할 수 있다.

<img width="1372" alt="스크린샷 2023-12-23 오후 11 27 14" src="https://github.com/jinyongyun/Credit_Card_List_APP/assets/102133961/7edefb82-8ea4-4e7d-8a3e-fc414405f51f">


Realtime 관련 ref는 주석처리해줬다.

이제 Realtime db로 처리했던 동일한 액션(입력 수정 삭제)을 Firestore를 통해 구현해보겠다.

CardListViewController에 **import** FirebaseFirestore 추가

아까 AppDelegate에서 했던 것처럼 db 추가

**var** db = Firestore.firestore()

db.collection("creditCardList").addSnapshotListener { snapshot, error **in**

}

실시간 데이터베이스에서 observe로 표현했던 것처럼 여기선 addSnapshotListener로 표현해준다.

각각의 표현과 바라보는 디비만 다를 뿐 문법은 거의 비슷하다! (아래를 viewDidLoad에 )

```swift
//Firestore 읽기
        db.collection("creditCardList").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("ERROR Firestore fetching document \(String(describing: error))")
                return
            }
            
            self.creditCardList = documents.compactMap { doc -> CreditCard? in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: doc.data(), options: [])
                    let creditCard = try JSONDecoder().decode(CreditCard.self, from: jsonData)
                    return creditCard
                } catch let error {
                    print("ERROR JSON Parsing \(error)")
                    return nil
                }
            }.sorted { $0.rank < $1.rank }
        }
```

creditCardList document를 바라볼 건데 

여기서 compactMap을 쓴 이유는 이 document에서 nil값을 반환했을 때 nil값을 배열 안에 넣지 않기 위해! 이렇게 써주면 데이터 읽기는 끗!

이제 데이터 쓰기를 해보겠다. 이녀석도 실시간 디비와 같이 경로를 알고 있는 옵션1과 모를 때 옵션2로 나뉘어진다. 

```swift
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //상세화면 전달하기
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController else { return }
        
        detailViewController.promotionDetail = creditCardList[indexPath.row].promotionDetail
        self.show(detailViewController, sender: nil)
        
        //실시간 데이터베이스 쓰기
//        // option 1 : key 지정 사용
//        let cardID = creditCardList[indexPath.row].id
//        ref.child("Item\(cardID)/isSelected").setValue(true)
        
//        //option 2 : 컴포넌트 물어봐
//        ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
//            guard let self = self,
//                  let value = snapshot.value as? [String: [String: Any]],
//                  let key = value.keys.first else {return}
//            
//            ref.child("\(key)/isSelected").setValue(true)
//        }
        
        //Firestore 쓰기
        //Option1 : 경로 알고 있어
        let cardID = creditCardList[indexPath.row].id
        //db.collection("creditCardList").document("card\(cardID)").updateData(["isSelected" : true])
        
        //Option2 : 경로를 몰라
        db.collection("creditCardList").whereField("id", isEqualTo: cardID).getDocuments { snapshot, _ in
            guard let document = snapshot?.documents.first else {
                print("ERROR Firestore fetching document")
                return
            }
            
            document.reference.updateData(["isSelected" : true]) //document의 reference에 updateData를 해라!
            
        }
    }
```

경로를 알고 있을 때는 cardID를 가져와서 db의 collection(이름은 creditCardList)의 document를 가져와 데이터를 업데이트 해주면 된다 (쏘 심플)

하지만 랜덤 값으로 ID를 부여할 수 있기 때문에 경로를 모르는 경우도 살펴봐야한다. 실시간 디비에서와 같이 아이디 검색을 통해 document를 가져오고 해당 document에 reference로 접근 후 updateData 해주면 된다!

마지막으로 데이터 삭제하기

이 역시 경로를 알 때와 모를 때로 나뉘어진다.

위의 코드와 비슷하고 delete 함수를 사용하는 것만 다르다.

```swift
override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //실시간 데이터베이스 삭제
//            //Option1
//            let cardID = creditCardList[indexPath.row].id
//            ref.child("Item\(cardID)").removeValue()
            
            //Option2 : 경로 몰라
//            ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
//                guard let self = self,
//                      let value = snapshot.value as? [String: [String: Any]],
//                      let key = value.keys.first else { return }
//                
//                self.ref.child(key).removeValue()
//
//            }
            
            //Firestore의 삭제
            //Option1 : 경로 알아
            let cardID = creditCardList[indexPath.row].id
            //db.collection("creditCardList").document("card\(cardID)").delete()
            //Option2 : 경로 몰라
            db.collection("creditCardList").whereField("id", isEqualTo: cardID).getDocuments { snapshot, _ in
                guard let document = snapshot?.documents.first else {
                    print("ERROR")
                    return
                }
                
                document.reference.delete()
            }
        }
    }
```


https://github.com/jinyongyun/Credit_Card_List_APP/assets/102133961/ed3d1b0b-a20f-45b0-8a86-8631ff9d358c

