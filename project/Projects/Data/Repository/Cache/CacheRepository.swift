//
//  CacheRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 9/21/24.
//

import UIKit
import UniformTypeIdentifiers
import Domain
import Core


import SDWebImageWebPCoder
import RxSwift

public protocol CacheRepository {
    
    /// 이미지 데이터를 획득합니다.
    func getImage(imageInfo: ImageDownLoadInfo) -> Single<UIImage>
}

struct ImageCacheInfo: Codable {
    let url: String
    let format: ImageFormat
    let date: Date
    
    func updateDate() -> Self {
        .init(
            url: url,
            format: format,
            date: .now
        )
    }
}

public class DefaultCacheRepository: CacheRepository {
    
    /// UserDefaults에 사여용되는 키
    enum Key {
        static let cacheInfoDict = "cacheInfoDictionary"
    }
    
    private let fileManagerScheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
    private let concurrentScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    /// 이미지를 메모리에서 캐싱하는 NSCache입니다.
    private let imageMemoryCache: NSCache<NSString, UIImage> = .init()
    
    /// 캐시정보를 저장하는 딕셔너리입니다. 키: url , 값: (disk path, time)
    private var cacheInfoDict: [String: ImageCacheInfo] {
        if let dict = UserDefaults.standard.dictionary(forKey: Key.cacheInfoDict) {
            
            return dict.mapValues { value in
                let data = value as! Data
                let decoded = try! jsonDecoder.decode(ImageCacheInfo.self, from: data)
                return decoded
            }
        }
        let newDict: [String: Data] = [:]
        UserDefaults.standard.set(newDict, forKey: Key.cacheInfoDict)
        return [:]
    }
    
    /// 디스크캐시
    let maxFileCount: Int
    let removeFileCountForOveflow: Int
    
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    
    public init(maxFileCount: Int = 50, removeFileCountForOveflow: Int = 10) {
        
        // 디스크 캐싱 옵션 설정
        self.maxFileCount = maxFileCount
        self.removeFileCountForOveflow = removeFileCountForOveflow
        
        // 이미지 인메모리 캐시 설정
        imageMemoryCache.countLimit = 30
        imageMemoryCache.totalCostLimit = 20
    }
    
    public func getImage(imageInfo: ImageDownLoadInfo) -> Single<UIImage> {
        
        let startTime: Date = .now
        
        // MARK: 이미지 캐싱정보 확인
        let findCacheResult = findCache(imageInfo: imageInfo)
            .subscribe(on: fileManagerScheduler)
            .asObservable()
            .share()
        
        let cacheFound = findCacheResult.compactMap { $0 }
        let cacheNotFound = findCacheResult.filter { $0 == nil }
        
        // MARK: 이미지 다운로드
        let imageDownloadResult = cacheNotFound
            .observe(on: concurrentScheduler)
            .map { [imageInfo] _ -> Data? in
                try? Data(contentsOf: imageInfo.imageURL)
            }
            .share()
        
        let downloadSuccess = imageDownloadResult.compactMap { $0 }
        
        // MARK: 다운로드된 이미지 캐싱
        let downloadedImage = downloadSuccess
            .observe(on: fileManagerScheduler)
            .map { [imageInfo, weak self] data in
                // 디스크에 이미지 캐싱
                self?.cacheImageFileToDisk(imageURL: imageInfo.imageURL, contents: data)
                
                return data
            }
            .observe(on: concurrentScheduler)
            .compactMap { [imageInfo, weak self] data in
                self?.cacheImageToMemory(
                    imageInfo: imageInfo,
                    contents: data
                )
            }
        
        return Observable
            .merge(
                downloadedImage.asObservable(),
                cacheFound.asObservable()
            )
            .map({ [startTime] image in
                let diff = Date.now.timeIntervalSince(startTime)
                printIfDebug("이미지 획득 종료, 소요시간(초): \(diff)")
                return image
            })
            .asSingle()
    }
    
    
    func findCache(imageInfo: ImageDownLoadInfo) -> Single<UIImage?> {
        
        Single<UIImage?>.create { [weak self] observer in
            
            let urlString = imageInfo.imageURL.absoluteString
            let cacheInfoKey = urlString
            let memoryKey = NSString(string: urlString)
            
            // MARK: 메모리 캐싱정보 체크
            if let image = self?.imageMemoryCache.object(forKey: memoryKey) {
                
                #if DEBUG
                print("key: \(cacheInfoKey) memory cache hit")
                #endif
                
                // 접근시간 업데이트
                self?.updateLastReadTime(cacheInfoKey: cacheInfoKey)
                
                observer(.success(image))
                
            } else {
                
                // MARK: 디스크 캐싱정보 체크
                if let image = self?.checkDiskCache(info: imageInfo) {
                    
                    #if DEBUG
                    print("key: \(cacheInfoKey) disk cache hit")
                    #endif
                    
                    // 접근시간 업데이트
                    self?.updateLastReadTime(cacheInfoKey: cacheInfoKey)
                    
                    // 메모리 캐시에 올리기
                    self?.imageMemoryCache.setObject(image, forKey: memoryKey)
                    
                    observer(.success(image))
                } else {
                    
                    // 캐싱된 이미지 정보 없음
                    observer(.success(nil))
                }
            }
            
            return Disposables.create { }
        }
    }
    
    func cacheImageToMemory(imageInfo: ImageDownLoadInfo, contents: Data) -> UIImage? {
    
        let urlString = imageInfo.imageURL.absoluteString
        let cacheInfoKey = urlString
        let memoryKey = NSString(string: urlString)
        
        // UIImage생성
        if let image = createUIImage(data: contents, format: imageInfo.imageFormat) {
            
            // 캐싱정보 지정
            let cacheInfo = ImageCacheInfo(
                url: imageInfo.imageURL.absoluteString,
                format: imageInfo.imageFormat,
                date: .now
            )
            
            var dict = cacheInfoDict
            dict[cacheInfoKey] = cacheInfo
            setCacheInfoDict(dict: dict)
            
            // 메모리 캐시에 올리기
            imageMemoryCache.setObject(image, forKey: memoryKey)
            
            // 캐싱 성공
            return image
        }
        
        // 캐싱 실패
        return nil
    }
}

// MARK: Cache info
extension DefaultCacheRepository {
    
    var getCurrentTime: String {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.string(from: .now)
    }
    
    /// 마지막으로 캐시를 읽은 시각 업데이트
    func updateLastReadTime(cacheInfoKey: String) {
        if let cacheInfo = cacheInfoDict[cacheInfoKey] {
            let updated = cacheInfo.updateDate()
            updateCacheInfoDict(key: cacheInfoKey, update: updated)
            
            #if DEBUG
            print("key: \(cacheInfoKey) Hit time updated")
            #endif
        }
    }
    
    /// 업데이트된 캐시정보를 저장합니다.
    func updateCacheInfoDict(key: String, update: ImageCacheInfo) {
        var dict = cacheInfoDict
        dict[key] = update
        setCacheInfoDict(dict: dict)
    }
    
    func setCacheInfoDict(dict: [String: ImageCacheInfo]) {
        let encoded = dict.mapValues { info in
            try! jsonEncoder.encode(info)
        }
        UserDefaults.standard.set(encoded, forKey: Key.cacheInfoDict)
    }
}

// MARK: Checking disk
extension DefaultCacheRepository {
    
    /// image경로를 획득합니다.
    @discardableResult
    func createImagePath(url: String) -> URL? {
        
        guard let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            #if DEBUG
            print("\(url) 이미지 경로 생성 실패")
            #endif
            return nil
        }
        
        let imageDirectoryPath = path.appendingPathComponent("Image")
        
        if !FileManager.default.fileExists(atPath: imageDirectoryPath.path) {
                
            do {
                try FileManager.default.createDirectory(at: imageDirectoryPath, withIntermediateDirectories: true)
            } catch {
                
                #if DEBUG
                print("이미지 캐싱 디렉토리 생성 실패")
                #endif
                
                return nil
            }
        }
        
        let imageFileName = safeFileName(from: url)
        
        let imageURL = imageDirectoryPath
            .appendingPathComponent(imageFileName)
        return imageURL
    }
    
    /// 디스크 캐시를 확인합니다.
    @discardableResult
    func checkDiskCache(info: ImageDownLoadInfo) -> UIImage? {
        
        guard let imagePath = createImagePath(url: info.imageURL.absoluteString) else {
            return nil
        }
        
        if FileManager.default.fileExists(atPath: imagePath.path) {
            
            // 이미지 파일이 존재
            
            printIfDebug("\(info.imageURL) : 디스크에 파일이 존재함")
            
            if let data = FileManager.default.contents(atPath: imagePath.path) {
                
                return createUIImage(data: data, format: info.imageFormat)
            }
            
            printIfDebug("\(info.imageURL) : 파일이 존재하지만 데이터를 불러오지 못함")
            
            return nil
            
        } else {
            
            // 파일이 존재하지 않는 경우
            printIfDebug("디스크에 파일이 존재하지 않음")
            
            return nil
        }
    }
    
    func cacheImageFileToDisk(imageURL: URL, contents: Data) {
        
        guard let imagePath = createImagePath(url: imageURL.absoluteString) else {
            return
        }
        
        let imageDirectoryPath = imagePath.deletingLastPathComponent()
        
        if let numOfFiles = try? FileManager.default.contentsOfDirectory(atPath: imageDirectoryPath.path).count {
            
            // 최대 파일수를 초과한 경우 삭제(LRU), 하위 10개 파일 삭제
            if numOfFiles >= maxFileCount {
                #if DEBUG
                print("디스크 파일수가 50개를 초과하였음 삭제실행")
                #endif
                
                var dict = cacheInfoDict
                let sortedInfo = dict.sorted { (lhs, rhs) in
                    lhs.value.date < rhs.value.date
                }
                
                // 이미지 파일 삭제
                sortedInfo[0..<removeFileCountForOveflow].forEach { (key, value) in
                    dict.removeValue(forKey: key)
                    
                    if let path = createImagePath(url: value.url) {
                        
                        if FileManager.default.fileExists(atPath: path.path) {
                            
                            do {
                                try FileManager.default.removeItem(at: path)
                                print("이미지 삭제 성공 \(path)")
                            } catch {
                                #if DEBUG
                                print("\(path) 이미지 삭제 실패 reason: \(error.localizedDescription)")
                                #endif
                            }
                        } else {
                            #if DEBUG
                            print("\(path) 파일이 존재하지 않음")
                            #endif
                        }
                       
                    }
                }
                
                #if DEBUG
                print("디스크 파일삭제완료")
                #endif
                
                // 이미지 캐싱정보 저장 (10개 삭제)
                setCacheInfoDict(dict: dict)
            }
        }
        
        // 이미지 파일 생성
        let fileCreationResult = FileManager.default.createFile(atPath: imagePath.path, contents: contents)
        
        #if DEBUG
        print("디스크에 이미지 생성 \(fileCreationResult ? "성공" : "실패") 경로: \(imagePath)")
        #endif
    }
    
    @discardableResult
    func createUIImage(data: Data, format: ImageFormat) -> UIImage? {
        var image: UIImage?
        if format == .webp {
            image = SDImageWebPCoder.shared.decodedImage(with: data)
        } else {
            image = UIImage(data: data)
        }
        
        if let image {
            
            return image
        }
        return nil
        #if DEBUG
        print("이미지 다운로드 싪패")
        #endif
    }
    
    func safeFileName(from url: String) -> String {
        let unsafeCharacters: [String: String] = [
            "/": "_",    // 슬래시 -> 언더바
            ":": "_",    // 콜론 -> 언더바
            "?": "_",    // 물음표 -> 언더바
            "=": "_",    // 등호 -> 언더바
            "&": "_",    // 앰퍼샌드 -> 언더바
            "%": "_",    // 퍼센트 -> 언더바
            "#": "_",    // 해시 -> 언더바
            " ": "_",    // 공백 -> 언더바
            "\"": "_",   // 쌍따옴표 -> 언더바
            "'": "_",    // 작은따옴표 -> 언더바
            "<": "_",    // 꺾쇠 -> 언더바
            ">": "_",    // 꺾쇠 -> 언더바
            "\\": "_",   // 역슬래시 -> 언더바
            "|": "_",    // 파이프 -> 언더바
            "*": "_",    // 별표 -> 언더바
            ";": "_",    // 세미콜론 -> 언더바
        ]

        var safeFileName = url

        // 각 특수 문자를 안전한 문자로 변환
        for (unsafe, safe) in unsafeCharacters {
            safeFileName = safeFileName.replacingOccurrences(of: unsafe, with: safe)
        }

        return safeFileName
    }
    
    @discardableResult
    func clearImageCacheDirectory() -> Bool {
        
        guard let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("\(#function) 이미지 경로 생성 실패")
            return false
        }
        
        let imageDirectoryPath = path.appendingPathComponent("Image")
        
        do {
            try FileManager.default.removeItem(at: imageDirectoryPath)
            UserDefaults.standard.removeObject(forKey: Key.cacheInfoDict)
            print("\(#function) 이미지 캐싱정보 삭제성공")
            return true
        } catch {
            print("\(#function) 파일 삭제 실패")
            return false
        }
    }
}
