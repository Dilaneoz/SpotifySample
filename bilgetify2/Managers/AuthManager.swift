//
//  AuthManager.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import Foundation

final class AuthManager {
    
    static let shared = AuthManager()

    private var refreshingToken = false

    struct Constants {
        static let clientID = "42c3662502894e02a112341e73d78bb2"
        static let clientSecret = "b39a787ba02f448c8474b230f75cc815"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token" // token alıcağımız url
        static let redirectURI = "http://localhost:8888/callback" // token aldıktan sonra yönlendirilcek url
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email" // bizim uygulamamız üzerinden spotify a girecek kişinin erişebileceğimiz özellikleri (doğum tarihi, maillerini okuma, kütüphanesine erişebilme, takip ettiği şeyleri okuyabilme vs)
    }

    private init() {}

    public var signInURL: URL? { // spotify a log in isteğinde bulunduk. o da bize vermiş olduğumuz bilgilerle önce kim olduğumuzu sorgulattı sonra erişmek isteyen kişinin hangi özellikleri varsa onları da bize yetkilendirerek bir token verir. token ın da içinde parse ederek cacheToken fonksiyonundaki kodlar çalışır
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }

    var isSignedIn: Bool { // eğer accessToken nil değil ise demekki token alınmıştır. web sayfasından gitmiş izinler verilmiş sonra da yetkilendirildi ve ana sayfaya geldi (yani log in oldu) ve token verilmiş oldu
        return accessToken != nil
    }

    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }

    private var refreshToken: String? { // bankacılık uygulamalarında olduğu gibi sayfada 3 dk dan fazla hareket etmezsen oturum sonlanıyor. uygulamada ne kadar süre hareket etmezsen oturumun kapatılacağını belirleniyor
        return UserDefaults.standard.string(forKey: "refresh_token")
    }

    private var tokenExpirationDate: Date? { // uygulamada ne kadar süre hareket etmezsen oturumun kapatılacağını belirtir
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }

    private var shouldRefreshToken: Bool { // bir token ne kadar süre geçerli olucak
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }

    public func exchangeCodeForToken( // bize verilen token ın içerisindeki değerleri parse etmemiz gereken bir durum olur
        code: String, // exchangeCodeForToken fonksiyonuna bir code gelicek. bu code arkasında bool parametre alan bir completion handler çalışacak
        completion: @escaping ((Bool) -> Void) // escaping bir closure. bir fonksiyon parametre olarak bir closure alıyorsa ve bu closure da fonksiyonun dışında bir parametrede tutulmak istenirse (yani bir fonksiyonu başka bir fonksiyona parametre olarak gönderiyoruz ve bunun değerini bir değişkene aktarmak istersek escaping closure unu kullanıyoruz)
    ) {
        // Get Token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type",
                         value: "authorization_code"), // spotify ilgili servisi çağırmak istediğimi bu parametrelerle anlar
            URLQueryItem(name: "code",
                         value: code),
            URLQueryItem(name: "redirect_uri",
                         value: Constants.redirectURI),
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded ",
                         forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)

        let basicToken = Constants.clientID+":"+Constants.clientSecret // örneğin hangi clientID ile geldi
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }

        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField: "Authorization") // ya da Authorization ile geldi mi gibi

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data,
                  error == nil else {
                completion(false)
                return
            }

            do {
                print(data)
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result) // burayı debug modda açtığımızda, access_token, expires_in, refresh_token, scope(kullanıcının hangi alandan erişebileceğimiz) ve token_type bilgilerini görürüz
                completion(true)
            }
            catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }

    private var onRefreshBlocks = [((String) -> Void)]()

    /// Supplies valid token to be used with API Calls
    public func withValidToken(completion: @escaping (String) -> Void) { // ilgili token ımız valid değilse onu valid hale getiricek ve refreshtoken ı da alıp onu nsuserdefaults içinde sakladığımız accesstoken ile yer değiştiricek bi mekanizmaya ihtiyacımız var
        guard !refreshingToken else {
            // Append the compleiton
            onRefreshBlocks.append(completion)
            return
        }

        if shouldRefreshToken {
            // Refresh
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        }
        else if let token = accessToken {
            completion(token)
        }
    }

    public func refreshIfNeeded(completion: ((Bool) -> Void)?) {
        guard !refreshingToken else {
            return
        }

        guard shouldRefreshToken else {
            completion?(true)
            return
        }

        guard let refreshToken = self.refreshToken else{
            return
        }

        // Refresh the token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }

        refreshingToken = true

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type",
                         value: "refresh_token"),
            URLQueryItem(name: "refresh_token",
                         value: refreshToken),
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded ",
                         forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)

        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion?(false)
            return
        }

        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.refreshingToken = false
            guard let data = data,
                  error == nil else {
                completion?(false)
                return
            }

            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach { $0(result.access_token) }
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                completion?(true)
            }
            catch {
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()
    }
    // NSUserDefaults içinde access_token/refresh_token/expires_in bilgilerini saklayak bir fonksiyondur bu
    private func cacheToken(result: AuthResponse) { // cache - örneğin bir haber sitesinde sayfa dakikada bir gidip gelir. bu sırada database den veriler/haberler çekilir ve biz o sayfayı talep ettiğimiz için cache ile ara bir belleğe alınır. bir dakika boyunca tüm veriler ram imizde tutulur. ama o haber 10. saniyede gelirse göremiyoruz 1. dakikadan sonra görebiliyoruz, yani cache in süresi bittiğinde. birinci dakika dolunca database e gidip haberler tekrar çekilir
        // token ları bir yerde saklamak gereklidir. burada NSUserDefaults un yaptığı da odur. token ları cacheToken fonksiyonu ile NSUserDefaults un içinde saklıyoruz. spotify ın bize vermiş olduğu token ı alıp UserDefaults ile uygulamamızın içinde saklıyoruz
        UserDefaults.standard.setValue(result.access_token,
                                       forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token,
                                           forKey: "refresh_token") // süresi biten token ın yenilenmesi
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)),
                                       forKey: "expirationDate") // token ın ne kadar süreyle geçerli olduğu
    }

    public func signOut(completion: (Bool) -> Void) {
        UserDefaults.standard.setValue(nil,
                                       forKey: "access_token")
        UserDefaults.standard.setValue(nil,
                                       forKey: "refresh_token")
        UserDefaults.standard.setValue(nil,
                                       forKey: "expirationDate")

        completion(true)
    }
}
