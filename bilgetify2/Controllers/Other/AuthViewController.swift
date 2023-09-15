//
//  AuthViewController.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import UIKit
import WebKit
// completion handler bir fonksiyonun işlemleri bittiğinde çağırılan kod bloğuna verilen isimdir. closure adı verilen bir kod tipinden oluşur. ilk olarak, completion handler bloğunu eklediğimiz ana fonksiyon çağırılır ve fonksiyonun gövde kısmında yer alan satırlar çalışır (yani fonksiyonun ana kısmı). bu kısım tamamlandığında completion handler çağırılır ve bu bloğun içindeki kodlar çalışır. burada önemli olan nokta ana fonksiyonun ve completion handler bloğunun her zaman arka arkaya çalışmadığıdır. ana fonksiyon çalışırken, arka planda aynı zamanda başka kod blokları da çalışabilir. completion handler kod bloğunu ne zaman kullanmak isteyebiliriz : akla ilk gelen soru direkt arka arkaya iki normal fonksiyon çağıramaz mıyız? olur. bunu yapabiliriz ama bazen çalışması uzun sürecek olan bir fonksiyonumuz olabilir. örneğin internetten veri çekmek istiyoruz. elbette bu kodun çalışması zaman alacaktır. bu işlem sürerken uygulamanın geri kalanının tamamen durup ekranın donmasını istemeyiz. bunu önlemek için asenkron bir şekilde fonksiyonları çağırabiliriz. bunu anlamak için önce thread(iplik) kavramını öğrenmeliyiz. thread i bi işi aynı anda bir kişinin değil birden fazla kişinin daha kısa sürede yapması gibi düşünebiliriz (benim işim bitti sıradaki işim ne olucak gibi senkronizasyon işlemleri de yapabiliyoruz. bu network programlamaya kadar gidiyor). aynı thread üzerinde yer alan işlemler, teker teker ve sıralı bir şekilde çalışmak zorundadır ancak birden fazla thread kullanarak aynı anda birden fazla görevin çalışmasını sağlayabiliriz. thread de bir işe öncelik verilip diğer iş daha sonra yapılabilir. iki tane işi arka arkaya başlattığımız zaman ana thread in içerisinde (yani tek bir thread ile) bunu kullanırsak uygulama bloklanıyor yani ana ekran donuyor. bunu engellemek için arka arkaya yapılacak işlemlerde bunu başka birisinin asenkron olarak yapması aslında thread. aynı fonksiyonun içinde farklı bir thread de diğer işi çağırdığımız için ana thread etkilenmiyor ve kullanıcı butonlara vs basabiliyor, ekran donmuyor. asenkron çalışan fonksiyonlar sırayla çalışmak zorunda değildir. bir fonksiyon çağırılıp işine devam ederken başka kod blokları da çağırılabilir, tıpkı completion handler daki gibi. senkron da ise fonksiyonlar sırayla çalışır, birinin işi bitene kadar diğerinin işi başlamaz.
// completion handler daki parametre içindeki (data, urlresponse, error) kısmı fonksiyon çağırıldığında bize verinin çekilip çekilmediği hakkında çeşitli bilgiler verecektir. işlem başarılıysa 200 kodu döner başarısızsa 401 döner.
// completion handler olmasaydı, -örneğin bir film uygulamasında filmler yükleniyor- bir filmin yüklenmesi bitmeden diğer yüklenmeye başlamazdı. completion handler sayesinde asenkron olarak veriler yüklenir
class AuthViewController: UIViewController, WKNavigationDelegate {

    private let webView: WKWebView = { // webView bir web sayfasını bir mobil uygulama gibi göstermktir
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true // javascript özelliklerini kullanabilsin
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero,
                                configuration: config)
        return webView
    }()

    public var completionHandler: ((Bool) -> Void)? // geriye değer döndürmeyen ve arka planda çalışmasını istediğimiz bir fonksiyon

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        view.addSubview(webView)
        guard let url = AuthManager.shared.signInURL else { // sayfa yüklendiğinde webview a signinurl i göndericez
            return
        }
        webView.load(URLRequest(url: url))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds // bulunduğu view in tüm genişliği ve yüksekliğini alsın
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }

        // Exchange the code for access token
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code"  })?.value else { // burada yapılan : yukarıdaki url ile code (token ın kodu?) diye bir değer dönüyor (login olunduğunda, spotify gönderilmiş olunan verilere göre bir autanticationResponse denilen bir şey döner). anahtarı "code" olan değerini de benim alıcağım bir token vericek. yani queryItems ile beraber bana döndüğün datanın(token ın) içerisinde code diye bir şey varsa onun value sunu bana ver diyorum
            return
        }
        webView.isHidden = true // işlem bittiğinde webView gizlenir

        AuthManager.shared.exchangeCodeForToken(code: code) { [weak self] success in // completion handler yani arka planda çalışmasını istediğimiz kodla beraber eğer success ise, login olduysa, popToRootViewController geçilir
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
}

