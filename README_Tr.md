Elbette, aşağıda Türkçe çevirisi bulunan GitHub README dosyası:

![SwipeableTabBarController](./Resources/GIFs/SwipeableTabBarController_logo.gif)

[![Versiyon](https://img.shields.io/cocoapods/v/SwipeableTabBarController.svg)](http://cocoapods.org/pods/SwipeableTabBarController)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)
![Cartage](https://img.shields.io/badge/carthage-compatible-4BC51D.svg)
[![Lisans](https://img.shields.io/cocoapods/l/SwipeableTabBarController.svg)](http://cocoapods.org/pods/SwipeableTabBarController)
[![codebeat badge](https://codebeat.co/badges/0cb2f5b2-5bd1-4cbe-8581-3ca3df0e79ab)](https://codebeat.co/projects/github-com-marcosgriselli-swipeabletabbarcontroller-master)

## 🌟 Özellikler

- [x] Sıfır yapılandırma 
- [x] Farklı animasyonlar
- [x] Kolayca etkileşimleri etkinleştirme/devre dışı bırakma
- [x] Akıcı jestler

## 📲 Kurulum

#### [CocoaPods](https://cocoapods.org) kullanarak

`Podfile` dosyanızı düzenleyin ve bağımlılığı belirtin:

```ruby
pod 'SwipeableTabBarController'
```

#### [Carthage](https://github.com/carthage) kullanarak

`Cartfile` dosyanızı düzenleyin ve bağımlılığı belirtin:

```bash
github "marcosgriselli/SwipeableTabBarController"
```

#### Manuel

SwipeableTabBarController/Classes içindeki sınıfları projenize ekleyin.

## 👩‍💻 Nasıl Kullanılır

### Kurulum

Eğer `UITabBarController`'ü alt sınıflara ayırmak istemiyorsanız, Storyboard'daki `UITabBarController`'ü `SwipeableTabBarController` türünde ayarlayın.

Aksi takdirde, `SwipeableTabBarController`'ün alt sınıfını yapın.

```swift
import SwipeableTabBarController

class TabBarController: SwipeableTabBarController {
    // Diğer UITabBarController alt sınıfı gibi işlemleri yapın.
}
```

### Animasyonlar

`SwipeableTabBarController`, başlangıçta 3 farklı animasyon türünü destekler. İstenen animasyonu ayarlamak kolaydır. `SwipeableTabBarController` alt sınıfınızda aşağıdaki gibi yapın:

```swift
swipeAnimatedTransitioning?.animationType = SwipeAnimationType.sideBySide
```

Yalnızca bir tür animasyon destekliyorsanız, istenen animasyonu `viewDidLoad()` içinde çağırın. Aksi takdirde, istenen animasyonu değiştirmek için gerektiğinde çağırabilirsiniz.

#### Side

 by Side (varsayılan)

<a href="url"><img src="./Resources/GIFs/SideBySideAnimation.gif" height="216" width="125" ></a>

Varsayılan animasyon `SwipeAnimationType.sideBySide`'dır. Yeni seçilen sekme, öncekinin çıkış yaptığı hızda hareket eder.

#### Overlap (Üstüste binme)

<a href="url"><img src="./Resources/GIFs/OverlapAnimation.gif" height="240" width="125" ></a>

`SwipeAnimationType.overlap`, yeni seçilen sekmeyi öncekinin üzerine yerleştirerek orta alana yerleştirir.

#### Push (İtme)

<a href="url"><img src="./Resources/GIFs/PushAnimation.gif" height="240" width="125" ></a>

`SwipeAnimationType.push`, üst görünüm geriye hareket ederken alt görünüm hafifçe geri hareket eden iOS varsayılan itme animasyonunu takip eder. Bu durumda, üst görünüm önceki seçilen sekme görünümü olur.

<!-- 
### Restricted Swipe

Eğer yatay düzeyde mükemmel bir sürükleme veya çapraz hareketi desteklemek istiyorsanız seçebilirsiniz. Eğer scrollView veya Harita gibi denetleyiciler kullanan bir denetleyicide kullanmıyorsanız yatay kaydırma özelliğini etkinleştirmenizi öneririm.

Varsayılan değer ```false```

```swift
setDiagonalSwipe(enabled: true)
```
--->

### Döngüsel Geçiş Etkinleştirme

`SwipeableTabBarController`, bir kâruselel gibi ilk ve son sekme arasında döngüsel geçişi destekler. Sadece `isCyclingEnabled`'ı `true` olarak ayarlayın.

Varsayılan değer `false`'dur.
```swift
isCyclingEnabled = true
```

### Minimum/Maksimum dokunma sayısı

Kaydırma jestini işlemek için gereken minimum ve maksimum dokunma sayısını ayarlayabilirsiniz. Sadece `minimumNumberOfTouches` veya `maximumNumberOfTouches` özelliğini ayarlayın.

Varsayılan değer `1`'dir.
```swift
minimumNumberOfTouches = 2
```

Varsayılan değer `Int.max`'tır.
```swift
maximumNumberOfTouches = 2
```

### Etkileşimi Devre Dışı Bırakma

Etkileşimciyi devre dışı bırakma/etkinleştirme desteği, yatay bir scrollView veya harita (örnekte) kullanan bir denetleyicide kullanılabilir.

Varsayılan değer ```true```'dir.
```swift
isSwipeEnabled = false
```

## ❤️ Katkıda Bulunma
Bu, açık kaynak bir projedir, bu yüzden gönüllü katkıda bulunmaktan çekinmeyin. Nasıl mı?
- Bir [sorun](https://github.com/marcosgriselli/Sizes/issues/new) açın.
- [Twitter

](https://twitter.com/marcosgriselli) üzerinden geri bildirim gönderin.
- Kendi düzeltmelerinizi, önerilerinizi önerin ve değişikliklerle bir çekme isteği açın.

**Katkıda Bulunanlar**

[![](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/images/0)](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/links/0)[![](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/images/1)](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/links/1)[![](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/images/2)](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/links/2)[![](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/images/3)](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/links/3)[![](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/images/4)](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/links/4)[![](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/images/5)](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/links/5)[![](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/images/6)](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/links/6)[![](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/images/7)](https://sourcerer.io/fame/marcosgriselli/marcosgriselli/SwipeableTabBarController/links/7)

## 👨‍💻 Yazar

Marcos Griselli | <a href="url"><img src="./Resources/twitterIcon.png" height="17"></a> [@marcosgriselli](https://twitter.com/marcosgriselli)

[![Twitter Takip Et](https://img.shields.io/twitter/follow/marcosgriselli.svg?style=social)](https://twitter.com/marcosgriselli)

[![GitHub Takip Et](https://img.shields.io/github/followers/marcosgriselli.svg?style=social&label=Takip)](https://github.com/marcosgriselli)

## 🛡 Lisans

```
MIT Lisansı

Telif Hakkı (c) 2018 Marcos Griselli

Bu yazılım ve ilişkili belgelendirme dosyalarının (yazılım), işlemesi için herkese verilen iz

in
dışında, kullanımı, kopyalanması, değiştirilmesi, birleştirilmesi, yayılması, yayılması,
alt lisanslama, ve/veya satışı, ve yazılımın kopyalarının sağlanması da dahil olmak üzere
sınırlama olmadan aşağıdaki koşullara tabidir:

Yukarıdaki telif hakkı bildirimi ve bu izin bildirimi yazılımın tüm kopyalarına veya önemli
kısımlarına dahil edilmelidir.

YAZILIM "HİÇBİR GARANTİ İLE" TEMİN EDİLMEDİĞİ İÇİN, AÇIKÇA VEYA ZIMNEN, SATILABİLİRLİK,
BELİRLİ BİR AMACA UYGUNLUK VEYA İHLAL OLMADAN SATILABİLİRLİK VEYA BELİRLİ BİR AMACA UYGUNLUK
İÇİN GARANTİLER DAHİL ANCAK BUNLARLA SINIRLI OLMAMAK ÜZERE, HİÇBİR GARANTİ VERİLMEMEKTEDİR.
HERHANGİ BİR DURUMDA YAZARLAR VEYA TELİF HAKKI SAHİPLERİ HERHANGİ BİR TALEP, ZARAR VEYA DİĞER
YÜKÜMLÜLÜK İÇİN HERHANGİ BİR SORUMLULUK ÜSTLENMEZ VEYA BİR ANLAŞMA EYLEMİNDE BULUNMA
İLGİLİ YAZILIMLA İLGİLİ TAZMİNAT İÇİN İLGİLİ YAZILIMDAN SORUMLU OLACAKTIR.
```